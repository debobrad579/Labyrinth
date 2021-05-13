extends Camera2D

export var zoom_lerp_rate = 0.01
export var pixel_stretch_point = 170
export var max_scale = 2
export var min_scale = 1.2

var PlayerStats = ResourceLoader.PlayerStats

onready var topLeft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight
onready var players = get_tree().get_nodes_in_group("Players")

var scaler = 1
var all_players_dead = false

func _ready():
	set_limits()

func _physics_process(delta):
	players = get_tree().get_nodes_in_group("Players")
	set_player_boundaries()
	set_camera_scaling_and_positioning()
	
func set_player_boundaries():
	for player in players:
		if player.position.y > limit_bottom: 
			if player.player_id == 0:
				PlayerStats.health = 0
			else:
				PlayerStats.health_p2 = 0
			
		if player.position.x >= limit_right:
			player.position.x = limit_right
		elif player.position.x <= limit_left:
			player.position.x = limit_left

func set_camera_scaling_and_positioning():
	if len(players) == 1:
		position = players[0].position
		zoom = Vector2(1, 1)
		yield(get_tree(), "idle_frame")
		smoothing_enabled = true
	elif len(players) == 2:
		smoothing_enabled = true
		position = (players[0].position + players[1].position)/2
		var distance_players = (players[0].position - players[1].position).length()
		var distance_scale = distance_players / pixel_stretch_point
		
		if distance_scale > min_scale:
			if distance_scale > max_scale:
				scaler = lerp(scaler, 2, zoom_lerp_rate)
			else:
				scaler = lerp(scaler, distance_scale, zoom_lerp_rate)
		else:
			scaler = lerp(scaler, min_scale, zoom_lerp_rate)
			
		zoom = Vector2(1, 1) * scaler

func set_limits():
	limit_top = topLeft.position.y
	limit_left = topLeft.position.x
	limit_bottom = bottomRight.position.y
	limit_right = bottomRight.position.x
