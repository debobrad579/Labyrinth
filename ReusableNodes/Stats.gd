class_name EntityStats
extends Node

func _ready():
	self.health = maxHealth
	self.mana = maxMana

export(int) var maxHealth = 1 setget set_max_health
var health = maxHealth setget set_health

signal no_health
signal health_changed
signal max_health_changed(value)

func set_max_health(value):
	maxHealth = value
	self.health = min(health, maxHealth)
	emit_signal("max_health_changed", maxHealth)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

export(int) var maxMana = 1 setget set_max_mana
var mana = maxMana setget set_mana

signal mana_changed
signal max_mana_changed(value)

func set_max_mana(value):
	maxMana = value
	self.mana = min(mana, maxMana)
	self.mana = max(mana, 0)
	emit_signal("max_mana_changed", maxMana)
	
func set_mana(value):
	mana = value
	mana = max(mana, 0)
	emit_signal("mana_changed", mana)
