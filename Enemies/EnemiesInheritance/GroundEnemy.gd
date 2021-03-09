extends Enemy
class_name GroundEnemy

export var JUMP_STRENGTH = 150

enum wall {
	RIGHT
	LEFT
	BOTH
}

onready var rightWallDetector = $WallDetectors/RightWallDetector
onready var leftWallDetector = $WallDetectors/LeftWallDetector


func is_at_wall(wall_location = wall.BOTH):
	if wall_location == wall.BOTH:
		return rightWallDetector.is_colliding() or leftWallDetector.is_colliding()
	elif wall_location == wall.RIGHT:
		return rightWallDetector.is_colliding()
	elif wall_location == wall.LEFT:
		return leftWallDetector.is_colliding()
	else:
		return false
		
func jump():
	motion.y = -JUMP_STRENGTH
