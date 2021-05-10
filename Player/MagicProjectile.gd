extends Node2D

export var SPEED = 150

onready var sprite = $Sprite
onready var particles = $Particles2D
onready var player1 = get_tree().get_root().find_node("Player1", true, false)
onready var player2 = get_tree().get_root().find_node("Player2", true, false)

var players = 1
var closest_player = player1
var direction_x = 1
var direction_y = 0
var knockback_2 = 0
var motion = Vector2.ZERO

func _ready():
	if player2 != null:
		players = 2
	if players == 2:
		if player1.position.x - self.position.x > player2.position.x - self.position.x:
			closest_player = player1
		else:
			closest_player = player2
	if players == 1:
		closest_player = player1
	direction_y = closest_player.direction_facing.y
	direction_x = closest_player.direction_facing.x
	if direction_y == 0:
		if direction_x == -1:
			sprite.flip_h = true
			particles.position.x += 16
	else:
		sprite.rotation_degrees = direction_y * 90
		if direction_y == -1:
			particles.position.x += 8
			particles.position.y += 8
		else:
			particles.position.x += 8
			particles.position.y += -8

func _physics_process(delta):
	if direction_y == 0:
		motion.x = SPEED * delta * direction_x
	else:
		motion.y = SPEED * delta * direction_y
	translate(motion)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
