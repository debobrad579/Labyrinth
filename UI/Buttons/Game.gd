extends "Button.gd"

func _on_MenuButton_pressed():
	if label.text == "Normal":
		label.set_text("Hard")
	elif label.text == "Hard":
		label.set_text("Easy")
	elif label.text == "Easy":
		label.set_text("Normal")
