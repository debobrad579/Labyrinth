extends Area2D

export var STRENGTH = 1

func _on_LargeHealthPotion_body_entered(body):
	if body.stats.health < body.stats.maxHealth:
		body.stats.health += STRENGTH
		queue_free()

func _on_SmallHealthPotion_body_entered(body):
	if body.stats.health < body.stats.maxHealth:
		body.stats.health += STRENGTH
		queue_free()


func _on_MediumHealthPotion_body_entered(body):
	if body.stats.health < body.stats.maxHealth:
		body.stats.health += STRENGTH
		queue_free()
