extends Area2D

onready var collision = $CollisionShape2D
onready var texture = $CollisionShape2D/TextureRect

func _ready():
	texture.rect_size = collision.shape.extents * 2
	texture.rect_position = -collision.shape.extents
