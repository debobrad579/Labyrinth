extends Control

export var ANIMATION_SPEED = 0.3

var mp = 1 setget set_mp
var max_mp = 1 setget set_max_mp
var start = true
var percent = 0
var size = 64

func get_percent(a: float, b: float) -> float:
	percent = a/b
	return percent

onready var player = get_tree().get_root().find_node("Player1", true, false)
onready var magicUIFull = $MagicUIFull

func set_mp(value):
	mp = clamp(value, 0, max_mp)
	if magicUIFull != null and start == false and player.stats.mana >= 0:
		size = 64 * get_percent(player.stats.mana, player.stats.maxMana)

func set_max_mp(value):
	max_mp = max(value, 1)
	self.mp = min(mp, max_mp)
	
func _ready():
	self.max_mp = player.stats.maxMana
	self.mp = player.stats.mana
	player.stats.connect("mana_changed", self, "set_mp")
	player.stats.connect("max_mana_changed", self, "set_max_mp")
	start = false

func _physics_process(delta):
	magicUIFull.rect_size.x = move_toward(magicUIFull.rect_size.x, size, ANIMATION_SPEED)
