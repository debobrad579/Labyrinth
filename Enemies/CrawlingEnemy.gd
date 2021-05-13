extends "res://Enemies/EnemiesInheritance/Enemy.gd"

enum DIRECTION {LEFT = -1, RIGHT = 1}

export(DIRECTION) var WALKING_DIRECTION = DIRECTION.RIGHT

onready var floorDetector = $FloorDetector
onready var wallDetector = $WallDetector

func _ready():
	wallDetector.cast_to.x *= WALKING_DIRECTION
	
func _physics_process(delta):
	if wallDetector.is_colliding():
		global_position = wallDetector.get_collision_point()
		var normal = wallDetector.get_collision_normal()
		rotation = normal.rotated(deg2rad(90)).angle()
	else:
		floorDetector.rotation_degrees = -MAX_SPEED * 10 * WALKING_DIRECTION * delta
		if floorDetector.is_colliding():
			global_position.x = floorDetector.get_collision_point().x
			global_position.y = floorDetector.get_collision_point().y
			var normal = floorDetector.get_collision_normal()
			rotation = normal.rotated(deg2rad(90)).angle()
		else:
			rotation_degrees += 20 * WALKING_DIRECTION
