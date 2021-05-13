extends "res://Enemies/EnemiesInheritance/Enemy.gd"

enum MOVEMENT {LEFT = -1, RIGHT = 1, KNOCKBACK = 2}

export(MOVEMENT) var ENEMY_MOVEMENT = MOVEMENT.RIGHT
export var KNOCKBACK_FRICTION = 200
export var ACCELERATION = 250
export var GRAVITY = 300
export var KNOCKBACK_AMOUNT_X = 1
export var KNOCKBACK_AMOUNT_Y = 1

var state
var state_was
var snap_vector = Vector2.ZERO
var knockback_stop_vector = Vector2.ZERO

onready var floorDetectorLeft = $FloorDetectorLeft
onready var floorDetectorRight = $FloorDetectorRight
onready var slopeDetectorLeft = $SlopeDetectorLeft
onready var slopeDetectorRight = $SlopeDetectorRight
onready var wallDetectorLeft = $WallDetectorLeft
onready var wallDetectorRight = $WallDetectorRight

func slope_detected():
	return ((slopeDetectorLeft.is_colliding() or slopeDetectorRight.is_colliding())
	and not (wallDetectorRight.is_colliding() or wallDetectorLeft.is_colliding()))

func _ready():
	motion.y = 8
	state = ENEMY_MOVEMENT
	state_was = ENEMY_MOVEMENT

func _physics_process(delta):
	match state:
		MOVEMENT.RIGHT:
			apply_horizontal_force(delta)
			if not floorDetectorRight.is_colliding() or wallDetectorRight.is_colliding(): 
				state = MOVEMENT.LEFT
		MOVEMENT.LEFT:
			apply_horizontal_force(delta)
			if not floorDetectorLeft.is_colliding() or wallDetectorLeft.is_colliding(): 
				state = MOVEMENT.RIGHT
		MOVEMENT.KNOCKBACK:
			snap_vector = Vector2.ZERO
			motion = (motion.move_toward(knockback_stop_vector, 
			KNOCKBACK_FRICTION * delta))
			if motion.y == 0 or slope_detected():
				state = state_was
	if not slope_detected():
		apply_gravity(delta)
	move()

func move():
	(motion = move_and_slide_with_snap(motion, snap_vector * 4, 
	Vector2.UP, true, 4, deg2rad(46)))

func apply_horizontal_force(delta):
	if not (state == MOVEMENT.LEFT or state == MOVEMENT.RIGHT): return
	snap_vector = Vector2.DOWN
	motion.x += ACCELERATION * delta * state
	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)

func apply_gravity(delta):
		motion.y += GRAVITY * delta

func _on_Hurtbox_area_entered(area):
	._on_Hurtbox_area_entered(area)
	apply_knockback(area)
	
func apply_knockback(area):
	if area.knockback_x == 0 and area.knockback_y == 0: return
	state_was = state
	if sign(state_was) == sign(area.knockback_x):
		knockback_stop_vector = Vector2(sign(state_was) * MAX_SPEED, 0)
	else:
		knockback_stop_vector = Vector2.ZERO
	state = MOVEMENT.KNOCKBACK
	snap_vector = Vector2.ZERO
	motion = Vector2(area.knockback_x * KNOCKBACK_AMOUNT_X, -area.knockback_y 
	* KNOCKBACK_AMOUNT_Y)
