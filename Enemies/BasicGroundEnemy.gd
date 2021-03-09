extends KinematicBody2D

export var ACCELERATION = 300
export var MAX_SPEED = 30
export var FRICTION = 200
export var GRAVITY = 300

onready var RwallDetector = $RightWallDetector
onready var LwallDetector = $LeftWallDetector
onready var stats = $Stats

var motion = Vector2.ZERO
var knockback = Vector2.ZERO
var direction = -1

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	if RwallDetector.is_colliding():
		direction = -1
	if LwallDetector.is_colliding():
		direction = 1
	
	motion.x += direction * ACCELERATION * delta
	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED) 
	
	var gravity_vector = Vector2(0, GRAVITY)
	motion += gravity_vector * delta
	motion = move_and_slide(motion, -gravity_vector, true, 4, PI/4, false)
	
func _on_Hurtbox_area_entered(area):
	stats.health -= 1
	if area.knockback_2 == 0:
		knockback = Vector2(150, -100)
	else:
		knockback = Vector2(-150, -100)

func _on_Stats_no_health():
	queue_free()
