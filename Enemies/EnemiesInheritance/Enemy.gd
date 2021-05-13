extends KinematicBody2D

export var MAX_SPEED = 30

var motion = Vector2.ZERO

onready var enemyStats = $EnemyStats

func _on_Hurtbox_area_entered(area):
	enemyStats.health -= area.damage

func _on_EnemyStats_no_health():
	queue_free()
