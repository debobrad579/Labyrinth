extends Area2D

export var STRENGTH = 1

func _on_LargeManaPotion_body_entered(body):
	if body.stats.mana < body.stats.maxMana:
		body.stats.mana += STRENGTH
		queue_free()

func _on_MediumManaPotion_body_entered(body):
	if body.stats.mana < body.stats.maxMana:
		body.stats.mana += STRENGTH
		queue_free()

func _on_SmallManaPotion_body_entered(body):
	if body.stats.mana < body.stats.maxMana:
		body.stats.mana += STRENGTH
		queue_free()
