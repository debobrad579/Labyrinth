extends KinematicBody2D

export var ACCELERATION = 300
export var MAX_SPEED = 30
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4

enum{
	IDLE,
	WANDER,
	CHASE
}

var motion = Vector2.ZERO
var knockback = Vector2.ZERO
var state = IDLE
# NEW VARIABLES:
# Controls when the pursuit timer is turned on or off. You should change this 
# to use the same mechanism that you used for the WanderController?
var pursuit_timer_active = false
# Since multiple players can play, this allows enenmies to target specific
# players. I have programmed it to chase the first player to enter the area.
# CHECK THE PLAYER DETECTION script!!
var target_player = null
# Aim is different. This will hold the relative difference between
# The monsters location and the players. For example, if the player 
# is 50px to the right and 10px down (FROM THE MONSTER), then the aim would be
# that... not the players global poisiton, which could be anything.
var aim = Vector2.ZERO

onready var stats = $Stats
onready var playerDetection = $PlayerDetection
onready var hurtbox = $Hurtbox
onready var wanderController = $WanderController
onready var objectDetector = $ObjectDetector

# NEW PRELOADS:
onready var pursuitTimer = $PursuitTimer
# Will attempt to load in Player1 and Player2 from the current scene. If
# Neither are present in the scene, they will return "null". (This is important
# for single player mode
onready var player1 = get_node_or_null('../Player1')
onready var player2 = get_node_or_null('../Player2')

func _ready():
	state = pick_random_state([IDLE, WANDER])
	
	# NOTE!! ----------------------------------------------------------------------
	# Due to a weird bug, the raycast won't initialize properly until the first
	# cast change, meaning if this isn't included, then the first time a player
	# enters the monster radius, even if there is a wall in the way, it will trigger
	# the chase scene before recognizing the wall. This somehow fixes that. -------
	if player1 != null: # <-- This is just to make sure that a crash error doesn't happen if the player doesn't load
		objectDetector.cast_to = player1.position - position
# Start at a random state.

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
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
				
	motion = move_and_slide(motion)
	

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	motion = motion.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	
func change_state():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))
# A random state between "IDLE", and "WANDER" is chosen then 
# the timer is reset to a time between 1 and 3 seconds.

# THIS FUNCTION IS THE OTHER MAJOR THING I CHANGED AND IS WHERE LINE
# OF SIGHT HAPPENS!
func seek_player():
	if playerDetection.can_see_player():
	
		# So if a player is detected, then it will check which
		# player is the first on the player detection list.
		# This is then assigned as the "target_player".
		if player1 == playerDetection.players[0]:
			target_player = player1
		elif player2 == playerDetection.players[0]:
			target_player = player2
		
		# Cast the raycast at the target player (position is different from
		# cast_to. Cast_to is the tip relative to position. In this case
		# We want to move the tip, not position.
		# Note that the cast_to is set to the players position relative to the 
		# monsters. Without the - position (minus monster's position) the
		# tip will not go to the player, but to the player + the monsters position
		# from the origin.
		objectDetector.cast_to = target_player.position - position
		
		# If not colliding, set aim and chase.
		if not objectDetector.is_colliding():
			# Aim is the relative position from the monster, aka the cast_to
			# position. They are the same.
			aim = objectDetector.cast_to
			state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
# This will pick a random state by shuffleing the states then picking the first one.

func _on_Hurtbox_area_entered(area):
	stats.health -= 1
	if area.knockback_2 == 0:
		knockback = Vector2.RIGHT * 150
	else:
		knockback = Vector2.LEFT * 150

func _on_Stats_no_health():
	queue_free()
