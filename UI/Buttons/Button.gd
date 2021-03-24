extends Button

export(String) var SCENE_TO_LOAD = null
export var HAS_FADE = false

onready var label = $Label
onready var fade = get_tree().get_root().find_node("Fade", true, false)
onready var timer = $Timer

func _ready():
	if HAS_FADE == true:
		fade.connect("fade_finished", self, "_fade_finished")

func _on_MenuButton_pressed():
	if HAS_FADE == true:
		fade.show()
		fade.fade_start()
	else:
		timer.start()
	
func _on_MenuButton_button_down():
	label.set_shadow_offset_y(0)
	label.set_shadow_offset_x(0)
	label.rect_position = Vector2(1, 1)

func _on_MenuButton_button_up():
	label.set_shadow_offset_y(1)
	label.set_shadow_offset_x(1)
	label.rect_position = Vector2.ZERO

func _fade_finished():
	get_tree().change_scene(SCENE_TO_LOAD)

func _on_Timer_timeout():
	if SCENE_TO_LOAD != null:
		get_tree().change_scene(SCENE_TO_LOAD)
