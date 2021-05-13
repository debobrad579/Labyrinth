extends "res://Enemies/EnemiesInheritance/Enemy.gd"

export var ACCELERATION = 300
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4
export var KNOCKBACK_AMOUNT_X = 1
export var KNOCKBACK_AMOUNT_Y = 0

enum{
	IDLE,
	WANDER,
	CHASE
}

var knockback = Vector2.ZERO
var state = IDLE
var pursuit_timer_active = false
var target_player = null
var aim = Vector2.ZERO

onready var playerDetection = $PlayerDetection
onready var hurtbox = $Hurtbox
onready var wanderController = $WanderController
onready var objectDetector = $ObjectDetector
onready var pursuitTimer = $PursuitTimer
onready var players = get_tree().get_nodes_in_group("Players")

func _ready():
	state = pick_random_state([IDLE, WANDER])
	
	if players.size() > 0: 
		objectDetector.cast_to = players[0].position - position

func _physics_process(delta):
	match state:
		IDLE:
			motion = motion.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				change_state()
		WANDER:
			seek_player()
		
			if wanderController.get_time_left() == 0:
				change_state()
				
			accelerate_towards_point(wanderController.targetPosition, delta)
			
			if global_position.distance_to(wanderController.targetPosition) <= WANDER_TARGET_RANGE:
				change_state()
			
		CHASE:
			seek_player()
			
			if objectDetector.is_colliding():
				set_pursuit_timer()
				
			accelerate_towards_point(position + aim, delta)
				
	motion = move_and_slide(motion)
	

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	motion = motion.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	
func change_state():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

func seek_player():
	if not playerDetection.can_see_player(): return
	
	select_target_player()
	
	if target_player != null:
		objectDetector.cast_to = target_player.position - position
	
	if not objectDetector.is_colliding():
		aim = objectDetector.cast_to
		state = CHASE

func select_target_player():
	if players.size() <= 0: return
	if players[0] == playerDetection.players[0]:
		target_player = players[0]
	elif players[1] == playerDetection.players[0]:
		target_player = players[1]
		
func set_pursuit_timer():
		if pursuit_timer_active == false:
			pursuitTimer.start()
			pursuit_timer_active = true
		elif pursuit_timer_active == true and pursuitTimer.is_stopped():
			pursuit_timer_active = false
			state = pick_random_state([IDLE, WANDER])
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	._on_Hurtbox_area_entered(area)
	apply_knockback(area)

func apply_knockback(area):
	motion = Vector2(area.knockback_x * KNOCKBACK_AMOUNT_X, -area.knockback_y 
	* KNOCKBACK_AMOUNT_Y)
