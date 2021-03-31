extends Control

var hearts = 1 setget set_hearts
var max_hearts = 1 setget set_max_hearts

onready var player = get_tree().get_root().find_node("Player1", true, false)
onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * 8

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * 8
	
func _ready():
	self.max_hearts = player.stats.maxHealth
	self.hearts = player.stats.health
	player.stats.connect("health_changed", self, "set_hearts")
	player.stats.connect("max_health_changed", self, "set_max_hearts")
