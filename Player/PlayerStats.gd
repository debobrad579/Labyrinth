extends Resource
class_name PlayerStats

export(int) var max_health = 6 setget set_max_health
var health = max_health setget set_health
export(int) var max_mana = 16 setget set_max_mana
var mana = max_mana setget set_mana
export(int) var max_health_p2 = 6 setget set_max_health_p2
var health_p2 = max_health_p2 setget set_health_p2
export(int) var max_mana_p2 = 16 setget set_max_mana_p2
var mana_p2 = max_mana_p2 setget set_mana_p2

var p2_exists = false

signal no_health
signal health_changed
signal max_health_changed(value)
signal no_health_p2
signal health_changed_p2
signal max_health_changed_p2(value)
signal mana_changed
signal max_mana_changed(value)
signal mana_changed_p2
signal max_mana_changed_p2(value)

func _ready():
	self.health = max_health
	self.mana = max_mana
	self.health_p2 = max_health_p2
	self.mana_p2 = max_mana_p2

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value):
	if value < health:
		Events.emit_signal("add_screenshake", 0.25, 0.4)
	health = value
	emit_signal("health_changed", health)
	health = clamp(health, 0, max_health)
	if health <= 0:
		emit_signal("no_health")

func set_max_mana(value):
	max_mana = value
	self.mana = min(mana, max_mana)
	self.mana = max(mana, 0)
	emit_signal("max_mana_changed", max_mana)
	
func set_mana(value):
	mana = value
	mana = max(mana, 0)
	emit_signal("mana_changed", mana)

func set_max_health_p2(value):
	max_health_p2 = value
	self.health_p2 = min(health_p2, max_health_p2)
	emit_signal("max_health_changed_p2", max_health_p2)

func set_health_p2(value):
	if value < health_p2:
		Events.emit_signal("add_screenshake", 0.25, 0.4)
	health_p2 = value
	emit_signal("health_changed_p2", health_p2)
	health_p2 = clamp(health_p2, 0, max_health_p2)
	if health_p2 <= 0:
		emit_signal("no_health_p2")

func set_max_mana_p2(value):
	max_mana_p2 = value
	self.mana_p2 = min(mana_p2, max_mana_p2)
	self.mana_p2 = max(mana_p2, 0)
	emit_signal("max_mana_changed_p2", max_mana_p2)
	
func set_mana_p2(value):
	mana_p2 = value
	mana_p2 = max(mana_p2, 0)
	emit_signal("mana_changed_p2", mana_p2)
