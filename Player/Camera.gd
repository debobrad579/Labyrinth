extends Camera2D

onready var topLeft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight

func _ready():
	limit_top = topLeft.position.y
	limit_left = topLeft.position.x
	limit_bottom = bottomRight.position.y
	limit_right = bottomRight.position.x

# Get the player nodes from the player group (as a list)
onready var players = get_tree().get_nodes_in_group("Players")

# Set up some camera scaling variables
var scaler = 1
var all_players_dead = false

export var zoom_lerp_rate = 0.01
export var pixel_stretch_point = 170
export var max_scale = 2
export var min_scale = 1.2

# For physics processs (yay!)
func _physics_process(delta):
	
	players = get_tree().get_nodes_in_group("Players")
	
	for player in players:
		if player.position.y > limit_bottom: 
			player.stats.health = 0
	
	if len(players) == 1:

	# Set position to player
		position = players[0].position
		zoom = Vector2(1, 1)
		


	elif len(players) == 2: # if 2 players. If no players, or more than 2, currently camera just does not move.

	# Position is the average of the two players
		position = (players[0].position + players[1].position)/2
	
	# Get distance between players as a vector length (number)
		var distance_players = (players[0].position - players[1].position).length()
	
	# If the players distance exceeds the pixel stretch point, then start scaling the camera
		var distance_scale = distance_players / pixel_stretch_point
	
	# If distance scale is greater than 1 (players are past pixel stretch point)
	# Then scale up
		if distance_scale > min_scale:
		
		# Don't scale past max_scale (Screen cannot be larger than that scale level)
			if distance_scale > max_scale:
			
			# lerp is used to create a smooth scaling, otherwise players moving in and out of the
			# Pixel stretch point would result in aggresive zooming in and out
				scaler = lerp(scaler, 2, zoom_lerp_rate)
			
			else:
		
				scaler = lerp(scaler, distance_scale, zoom_lerp_rate)
	
	# If distance scale is less than 1 (so players are within pixel stretch point)
	# scale back to 1
		else:
		
			scaler = lerp(scaler, min_scale, zoom_lerp_rate)
	
	# Zoom, a vector, is multiplied by the scaler, or the scale value
		zoom = Vector2(1, 1) * scaler
