extends Node

func _ready():
	self.health = max_health

export(int) var max_health = 1
var health = max_health setget set_health

signal no_health

func set_health(value):
	health = value
	health = clamp(health, 0, max_health)
	if health <= 0:
		emit_signal("no_health")
