extends Area2D

export var SPEED = 150

var motion = Vector2.ZERO

func _physics_process(delta):
	position += motion * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Hitbox_area_entered(_area):
	queue_free()

func _on_Projectile_body_entered(_body):
	queue_free()
