extends Control

export var ANIMATION_SPEED = 30
export var P1_MAGIC_POSITION_X = 8
export var P1_MAGIC_POSITION_Y = 24
export var P2_MAGIC_POSITION_X = 8
export var P2_MAGIC_POSITION_Y = 56

var mp = 1 setget set_mp
var red_mp = 1 setget set_red_mp
var start = true
var red_start = true
var percent = 0
var size = 64
var red_size = 64
var players = 1

func _ready():
	if player2 != null:
		players = 2
	set_stats(players)
	connect_signals(players)
	set_texture_positions(players)

func _physics_process(delta):
	animate(delta)

func get_percent(a: float, b: float) -> float:
	percent = a/b
	return percent

onready var player = get_tree().get_root().find_node("Player1", true, false)
onready var player2 = get_tree().get_root().find_node("Player2", true, false)
onready var magicUIFull = $MagicUIEmpty/MagicUIFull
onready var magicUIEmpty = $MagicUIEmpty
onready var magicUIFullRed = $MagicUIEmptyRed/MagicUIFullRed
onready var magicUIEmptyRed = $MagicUIEmptyRed

func set_mp(value):
	if player == null: return
	mp = clamp(value, 0, player.stats.maxMana)
	if magicUIFull != null and start == false and player.stats.mana >= 0:
		size = 64 * get_percent(player.stats.mana, player.stats.maxMana)
	start = false
		
func set_red_mp(value):
	if not players == 2 or player2 == null: return
	red_mp = clamp(value, 0, player2.stats.maxMana)
	if magicUIFullRed != null and red_start == false and player2.stats.mana >= 0:
		red_size = 64 * get_percent(player2.stats.mana, player2.stats.maxMana)
	if player2.stats.health == 0:
		red_size = 0
		magicUIFullRed.rect_size.x = 0
	red_start = false

# warning-ignore-all:shadowed_variable
func set_stats(players):
	if players == 1:
		self.mp = player.stats.mana
	else:
		self.mp = player2.stats.mana
		self.red_mp = player.stats.mana
		
func connect_signals(players):
	if players == 1:
		player.stats.connect("mana_changed", self, "set_mp")
	else:
		player2.stats.connect("mana_changed", self, "set_mp")
		player.stats.connect("mana_changed", self, "set_red_mp")
	
func set_texture_positions(players):
	P1_MAGIC_POSITION_X = magicUIEmpty.rect_position.x
	P1_MAGIC_POSITION_Y = magicUIEmpty.rect_position.y
	P2_MAGIC_POSITION_X = magicUIEmptyRed.rect_position.x
	P2_MAGIC_POSITION_Y = magicUIEmptyRed.rect_position.y
	if players == 1:
		magicUIEmpty.rect_position = Vector2(P1_MAGIC_POSITION_X, P1_MAGIC_POSITION_Y)
		magicUIEmptyRed.visible = false
		magicUIFullRed.visible = false
		start = false
	else:
		magicUIEmpty.rect_position = Vector2(P1_MAGIC_POSITION_X, P1_MAGIC_POSITION_Y)
		magicUIEmptyRed.rect_position = Vector2(P2_MAGIC_POSITION_X, P2_MAGIC_POSITION_Y)
		
func animate(delta):
	(magicUIFull.rect_size.x = move_toward(magicUIFull.rect_size.x, size,
	 ANIMATION_SPEED * delta))
	
	if players == 2:
		(magicUIFullRed.rect_size.x = move_toward(magicUIFullRed.rect_size.x, 
		red_size, ANIMATION_SPEED * delta))
		
	if player != null and player.stats.health == 0:
		size = 0
		magicUIFull.rect_size.x = 0
		
	if player2 != null and player2.stats.health == 0:
		red_size = 0
		magicUIFullRed.rect_size.x = 0
