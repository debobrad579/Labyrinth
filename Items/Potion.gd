extends Area2D

enum TYPES {HEALTH = 1, MANA = 2}

export(TYPES) var TYPE = TYPES.HEALTH
export var STRENGTH = 1

var PlayerStats = ResourceLoader.PlayerStats

func _ready():
	connect("body_entered", self, "_on_Potion_body_entered")

func _on_Potion_body_entered(body):
	if TYPE == TYPES.HEALTH:
		if body.player_id == 0:
			if PlayerStats.health < PlayerStats.max_health:
				PlayerStats.health += STRENGTH
				queue_free()
		else:
			if PlayerStats.health_p2 < PlayerStats.max_health_p2:
				PlayerStats.health_p2 += STRENGTH
				queue_free()
	elif TYPE == TYPES.MANA:
		if body.player_id == 0:
			if PlayerStats.mana < PlayerStats.max_mana:
				PlayerStats.mana += STRENGTH
				queue_free()
		else:
			if PlayerStats.mana_p2 < PlayerStats.max_mana_p2:
				PlayerStats.mana_p2 += STRENGTH
				queue_free()
