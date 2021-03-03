extends Camera2D

onready var topLeft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight

func _ready():
	limit_top = topLeft.position.y
	limit_left = topLeft.position.x
	limit_bottom = bottomRight.position.y
	limit_right = bottomRight.position.x
	
# The standard node doesn't have a position, so the 
# TopLeft and BottomRight position2d nodes don't follow the camera anymore.
# For each area you the position2d nodes can be set up to give the camera limits.
