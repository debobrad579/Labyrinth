extends Control

var start_button = false

func _input(event):
	if event:
		if start_button == false:
			if Input.is_action_just_pressed("ui_up"):
				$Menu/Rows/Buttons/Play.grab_focus()
				start_button = true
			if Input.is_action_just_pressed("ui_down"):
				$Menu/Rows/Buttons/Settings.grab_focus()
				start_button = true
