extends Control

var start_button = false

func _input(event):
	if event:
		if start_button == false:
			if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_left"):
				$Menu/Rows/LeftButtons/Difficulty.grab_focus()
				start_button = true
			if Input.is_action_just_pressed("ui_down"):
				$Menu/Rows/RightButtons/Back.grab_focus()
				start_button = true
			if Input.is_action_just_pressed("ui_right"):
				$Menu/Rows/RightButtons/Sound.grab_focus()
				start_button = true
