extends Area2D

export var damage = 2

onready var animatedSprite = $AnimatedSprite

func _ready():
	animatedSprite.playing = true
