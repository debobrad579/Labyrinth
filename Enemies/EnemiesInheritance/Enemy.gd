class_name DefaultEnemy
extends KinematicBody2D

enum{
	IDLE,
	WANDER,
	CHASE
}

export var ACCELERATION = 300
export var MAX_SPEED = 30
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4
export var GRAVITY = 300
export var KNOCKBACK_STRENGTH_Y = 100
export var KNOCKBACK_STRENGTH_X = 150
export var AIR_BORNE = false
export var AI = false

var motion = Vector2.ZERO
var knockback = Vector2.ZERO
var aim = Vector2.ZERO
var target_player = null
var pursuit_timer_active = false
var state = IDLE

onready var players = get_tree().get_nodes_in_group("Players")
onready var objectDetector = $ObjectDetector
onready var stats = $Stats
onready var playerDetection = $PlayerDetection
onready var hurtbox = $Hurtbox
onready var wanderController = $WanderController
onready var pursuitTimer = $PursuitTimer

func _ready():
	if AI == true:
		if players.size() > 0:
			objectDetector.cast_to = players[0].position - position
	if AIR_BORNE == true:
		KNOCKBACK_STRENGTH_Y = 0

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	print(motion.x)
	print(state)
	if AI == true:
		match state:
			IDLE:
				motion = motion.move_toward(Vector2.ZERO, FRICTION * delta)
			# If the enemy was moving, it will slow to a stop.
				seek_player()
			# The enemy searches for the player while in the "IDLE" state.
				
				if wanderController.get_time_left() == 0:
					change_state()
			WANDER:
				seek_player()
			# The enemy still searches for the player while in the "WANDER" state.
			
				if wanderController.get_time_left() == 0:
					change_state()
				# After a certain amount of time, the enemy will choose a random state.
				
				accelerate_towards_point(wanderController.targetPosition, delta)
				if global_position.distance_to(wanderController.targetPosition) <= WANDER_TARGET_RANGE:
					change_state()
			# If the player is not detected and the enemy's "WANDER" state is chosen, the
			# enemy will chose a spot to wander to, then move towards that spot. The enemy
			# will then choose a random state.
				
			CHASE:
				# Added seek_player() in here, just so the monster keeps
				# checking line of sight.
				seek_player()
				
				# If the object detector is colliding, but the state is still
				# CHASE, then check the timer
				if objectDetector.is_colliding():
					# If the timer hasn't started yet, start it.
					if pursuit_timer_active == false:
						pursuitTimer.start()
						pursuit_timer_active = true
						
					# if the timer has started, but run out, then switch states.
					# This gives the monster a 3 second pursuit length, but this
					# can be changed under the 'PursuitTimer' node.
					elif pursuit_timer_active == true and pursuitTimer.is_stopped():
						pursuit_timer_active = false
						state = pick_random_state([IDLE, WANDER])
				
				# NOTE THE AIM! Aim is the relative position from the monster, so
				# One the player moves out of the 'line of sight' aim is perserved
				# as the last location, so the monster keeps moving in that direction.
				# Note that this acts like the monster keeps moving in a given
				# direction. I can explain this more if you want.
				accelerate_towards_point(position + aim, delta)
				print(aim)
	if AIR_BORNE == false:
		var gravity_vector = Vector2(0, GRAVITY)
		motion += gravity_vector * delta
		motion = move_and_slide(motion, -gravity_vector, true, 4, PI/4, false)
	else:
		motion = move_and_slide(motion)

func seek_player():
	if playerDetection.can_see_player():
		
		if players.size() > 0:
		# So if a player is detected, then it will check which
		# player is the first on the player detection list.
		# This is then assigned as the "target_player".
			if players[0] == playerDetection.players[0]:
				target_player = players[0]
			elif players[1] == playerDetection.players[0]:
				target_player = players[1]
		
		# Cast the raycast at the target player (position is different from
		# cast_to. Cast_to is the tip relative to position. In this case
		# We want to move the tip, not position.
		# Note that the cast_to is set to the players position relative to the 
		# monsters. Without the - position (minus monster's position) the
		# tip will not go to the player, but to the player + the monsters position
		# from the origin.
		if target_player != null:
			objectDetector.cast_to = target_player.position - position
			
		if not objectDetector.is_colliding():
			aim = objectDetector.cast_to
			state = CHASE
			
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	if AIR_BORNE == true:
		motion = motion.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	else:
		motion.x = motion.move_toward(direction * MAX_SPEED, ACCELERATION * delta).x
			
func change_state():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
		
func _on_Hurtbox_area_entered(area):
	stats.health -= 1
	if area.knockback_2 == 0:
		knockback = Vector2(KNOCKBACK_STRENGTH_X, -KNOCKBACK_STRENGTH_Y)
	else:
		knockback = Vector2(-KNOCKBACK_STRENGTH_X, -KNOCKBACK_STRENGTH_Y)

func _on_Stats_no_health():
	queue_free()
