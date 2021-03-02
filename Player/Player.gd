extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 90
export var GRAVITY = 300
export var JUMP_FORCE = 128
export var FRICTION = 0.25
export var AIR_RISISTANCE = 0.02
export var WALL_SLIDE_ACCELERATION = 2
export var MAX_WALL_SLIDE_SPEED = 30
export var DOUBLE_JUMP_TOTAL = 1

onready var floorDetector = $FloorDetector
onready var jumpTimer = $Timer
onready var jumpTimer2 = $Timer2
onready var moveTimer = $Timer3
onready var moveTimer2 = $Timer4

var motion = Vector2.ZERO
var on_floor = false
var jump = false
var can_move = true
var wall_jump = false
var double_jump = DOUBLE_JUMP_TOTAL
var wall_double_jump = true
var can_resist = false

func _physics_process(delta):
	var x_input = Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")
		
	if x_input != 0 and can_move == true:
		motion.x += x_input * ACCELERATION * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		
	if on_floor == true:
		ACCELERATION = 500
		wall_double_jump = true
		double_jump = DOUBLE_JUMP_TOTAL
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION)
		if Input.is_action_just_pressed("jump"):
			motion.y = -JUMP_FORCE
			jump = true
			jumpTimer2.start()
	else:
		if Input.is_action_just_released("jump") and motion.y < -JUMP_FORCE/2 and wall_jump == false:
			motion.y = -JUMP_FORCE/2
			
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RISISTANCE)
		if double_jump > 0 and Input.is_action_just_pressed("jump") and is_on_wall() == false:
			motion.y = -JUMP_FORCE
			if Input.is_action_pressed("walk_right"):
				motion.x = MAX_SPEED
			if Input.is_action_pressed("walk_left"):
				motion.x = -MAX_SPEED
			can_move = true
			double_jump = 0
			
	if is_on_wall() and on_floor == false:
		if Input.is_action_pressed("walk_right") and motion.x < 0 or Input.is_action_pressed("walk_left") and motion.x > 0:
			can_move = true
		if Input.is_action_just_pressed("jump") and Input.is_action_pressed("walk_right"):
			ACCELERATION = 500
			motion.y = -JUMP_FORCE
			motion.x = -450
			can_move = false
			wall_jump = true
			moveTimer.start()
			motion.x = lerp(motion.x, 0, 0.835)
			if wall_double_jump == true and double_jump == 0:
				double_jump = DOUBLE_JUMP_TOTAL
				wall_double_jump = false
		elif Input.is_action_just_pressed("jump") and Input.is_action_pressed("walk_left"):
			motion.y = -JUMP_FORCE
			motion.x = 450
			can_move = false
			wall_jump = true
			moveTimer.start()
			motion.x = lerp(motion.x, 0, 0.835)
			if wall_double_jump == true and double_jump == 0:
				double_jump = DOUBLE_JUMP_TOTAL
				wall_double_jump = false
		if motion.y >= 0:
			motion.y = min(motion.y + WALL_SLIDE_ACCELERATION, MAX_WALL_SLIDE_SPEED)
	
	motion.y += GRAVITY * delta
	motion = move_and_slide(motion)

func _on_FloorDetector_body_entered(_body):
	on_floor = true
	wall_jump = false

func _on_FloorDetector_body_exited(_body):
	if jump == false:
		jumpTimer.start()
	else:
		on_floor = false

func _on_Timer_timeout():
	on_floor = false

func _on_Timer2_timeout():
	jump = false

func _on_Timer3_timeout():
	can_move = true
	moveTimer2.start()
	ACCELERATION = 200

func _on_Timer4_timeout():
	ACCELERATION = 500
