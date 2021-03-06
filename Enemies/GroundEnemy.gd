extends KinematicBody2D

export var ACCELERATION = 300
export var MAX_SPEED = 30
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4

enum{
	IDEL,
	WANDER,
	CHASE
}

var motion = Vector2.ZERO
var state = IDEL

onready var stats = $Stats
onready var playerDetection = $PlayerDetection
onready var hurtbox = $Hurtbox
onready var wanderController = $WanderController

func _ready():
	state = pick_random_state([IDEL, WANDER])
# Start at a random state.

func _physics_process(delta):
	
	match state:
		IDEL:
			motion = motion.move_toward(Vector2.ZERO, FRICTION * delta)
		# If the enemy was moving, it will slow to a stop.
			seek_player()
		# The enemy searches for the player while in the "IDEL" state.
			
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
			var player = playerDetection.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDEL
		# The enemy will move towards the player if the player is detected.
				
	motion = move_and_slide(motion)

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	motion.x = motion.move_toward(direction * MAX_SPEED, ACCELERATION * delta).x
# The enemy will move towards a specific point.
	
func change_state():
	state = pick_random_state([IDEL, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))
# A random state between "IDEL", and "WANDER" is chosen then 
# the timer is reset to a time between 1 and 3 seconds.

func seek_player():
	if playerDetection.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
# This will pick a random state by shuffleing the states then picking the first one.

