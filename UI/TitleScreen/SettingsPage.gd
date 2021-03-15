extends Control

var start_button = false

func _physics_process(_delta):
	if start_button == false:
		if Input.is_action_just_pressed("ui_up"):
			$Menu/Rows/LeftButtons/Difficulty.grab_focus()
			start_button = true
		if Input.is_action_just_pressed("ui_down"):
			$Menu/Rows/LeftButtons/Back.grab_focus()
			start_button = true
