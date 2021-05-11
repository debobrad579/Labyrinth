extends KinematicBody2D

export var MAX_SPEED = 30

var motion = Vector2.ZERO

onready var stats = $Stats

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage

func _on_Stats_no_health():
	queue_free()
