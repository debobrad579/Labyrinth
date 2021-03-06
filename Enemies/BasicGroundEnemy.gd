extends KinematicBody2D

export var ACCELERATION = 300
export var MAX_SPEED = 30
export var FRICTION = 200
export var GRAVITY = 300

onready var RwallDetector = $RightWallDetector
onready var LwallDetector = $LeftWallDetector

var motion = Vector2.ZERO
var direction = -1

func _physics_process(delta):
	
	if RwallDetector.is_colliding():
		direction = -1
	if LwallDetector.is_colliding():
		direction = 1
	
	motion.x += direction * ACCELERATION * delta
	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED) 
	
	var gravity_vector = Vector2(0, GRAVITY)
	motion += gravity_vector * delta
	motion = move_and_slide(motion, -gravity_vector, true, 4, PI/4, false)
	

