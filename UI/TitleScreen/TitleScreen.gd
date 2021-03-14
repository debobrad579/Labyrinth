extends Control

var start_button = false

func _physics_process(_delta):
	if start_button == false:
		if Input.is_action_just_pressed("ui_up"):
			$Buttons/Play.grab_focus()
			start_button = true
		if Input.is_action_just_pressed("ui_down"):
			$Buttons/Settings.grab_focus()
			start_button = true
