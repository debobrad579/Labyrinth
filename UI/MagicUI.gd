extends Control

export var ANIMATION_SPEED = 30
export var P1_MAGIC_POSITION_X = 8
export var P1_MAGIC_POSITION_Y = 24
export var P2_MAGIC_POSITION_X = 8
export var P2_MAGIC_POSITION_Y = 56

var PlayerStats = ResourceLoader.PlayerStats

var mp = 1 setget set_mp
var red_mp = 1 setget set_red_mp
var start = true
var red_start = true
var percent = 0
var size = 64
var red_size = 64
var players = 1

func _ready():
	if PlayerStats.p2_exists:
		players = 2
	set_stats(players)
	connect_signals(players)
	set_texture_positions(players)

func _physics_process(delta):
	animate(delta)

func get_percent(a: float, b: float) -> float:
	percent = a/b
	return percent

onready var magicUIFull = $MagicUIEmpty/MagicUIFull
onready var magicUIEmpty = $MagicUIEmpty
onready var magicUIFullRed = $MagicUIEmptyRed/MagicUIFullRed
onready var magicUIEmptyRed = $MagicUIEmptyRed

func set_mp(value):
	mp = clamp(value, 0, PlayerStats.max_mana)
	if magicUIFull != null and start == false and PlayerStats.mana >= 0:
		size = 64 * get_percent(PlayerStats.mana, PlayerStats.max_mana)
	start = false
		
func set_red_mp(value):
	if not players == 2: return
	red_mp = clamp(value, 0, PlayerStats.max_mana_p2)
	if magicUIFullRed != null and red_start == false and PlayerStats.mana_p2 >= 0:
		red_size = 64 * get_percent(PlayerStats.mana_p2, PlayerStats.max_mana_p2)
	if PlayerStats.health_p2 == 0:
		red_size = 0
		magicUIFullRed.rect_size.x = 0
	red_start = false

# warning-ignore-all:shadowed_variable
func set_stats(players):
	if players == 1:
		self.mp = PlayerStats.mana
	else:
		self.mp = PlayerStats.mana_p2
		self.red_mp = PlayerStats.mana_p2
		
func connect_signals(players):
	if players == 1:
		PlayerStats.connect("mana_changed", self, "set_mp")
	else:
		PlayerStats.connect("mana_changed", self, "set_red_mp")
		PlayerStats.connect("mana_changed_p2", self, "set_mp")

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
		
	if PlayerStats.health == 0:
		size = 0
		magicUIFull.rect_size.x = 0
		
	if PlayerStats.health_p2 == 0:
		red_size = 0
		magicUIFullRed.rect_size.x = 0
