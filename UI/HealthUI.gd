extends Control

export var P1_HEART_POSITION_X = 8
export var P1_HEART_POSITION_Y = 8
export var P2_HEART_POSITION_X = 8
export var P2_HEART_POSITION_Y = 40

var hearts = 1 setget set_hearts
var max_hearts = 1 setget set_max_hearts
var blue_hearts = 1 setget set_blue_hearts
var max_blue_hearts = 1 setget set_max_blue_hearts
var players = 1

onready var player = get_tree().get_root().find_node("Player1", true, false)
onready var player2 = get_tree().get_root().find_node("Player2", true, false)
onready var heartUIFull = $HeartUIEmpty/HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty
onready var heartUIFullBlue = $HeartUIEmptyBlue/HeartUIFullBlue
onready var heartUIEmptyBlue = $HeartUIEmptyBlue

func _ready():
	if player2 != null:
		players = 2
	set_stats(players)
	connect_signals(players)
	set_texture_positions(players)

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * 8

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * 8
		
func set_blue_hearts(value):
	blue_hearts = clamp(value, 0, max_blue_hearts)
	if heartUIFullBlue != null:
		heartUIFullBlue.rect_size.x = blue_hearts * 8
		
func set_max_blue_hearts(value):
	max_blue_hearts = max(value, 1)
	self.blue_hearts = min(blue_hearts, max_blue_hearts)
	if heartUIEmptyBlue != null:
		heartUIEmptyBlue.rect_size.x = max_blue_hearts * 8


# warning-ignore-all:shadowed_variable
func set_stats(players):
	if players == 1:
		self.max_hearts = player.stats.maxHealth
		self.hearts = player.stats.health
	else:
		self.max_blue_hearts = player.stats.maxHealth
		self.blue_hearts = player.stats.health
		self.max_hearts = player2.stats.maxHealth
		self.hearts = player2.stats.health
		
func connect_signals(players):
	if players == 1:
		player.stats.connect("health_changed", self, "set_hearts")
		player.stats.connect("max_health_changed", self, "set_max_hearts")
	else:
		player.stats.connect("health_changed", self, "set_blue_hearts")
		player.stats.connect("max_health_changed", self, "set_max_blue_hearts")
		player2.stats.connect("health_changed", self, "set_hearts")
		player2.stats.connect("max_health_changed", self, "set_max_hearts")
		
func set_texture_positions(players):
	P1_HEART_POSITION_X = heartUIEmptyBlue.rect_position.x
	P1_HEART_POSITION_Y = heartUIEmptyBlue.rect_position.y
	P2_HEART_POSITION_X = heartUIEmpty.rect_position.x
	P2_HEART_POSITION_Y = heartUIEmpty.rect_position.y
	if players == 1:
		heartUIEmpty.rect_position = Vector2(P1_HEART_POSITION_X, P1_HEART_POSITION_Y)
		heartUIFullBlue.visible = false
		heartUIEmptyBlue.visible = false
	else:
		heartUIEmptyBlue.rect_position = Vector2(P1_HEART_POSITION_X, P1_HEART_POSITION_Y)
		heartUIEmpty.rect_position = Vector2(P2_HEART_POSITION_X, P2_HEART_POSITION_Y)
