extends ColorRect

onready var animationPlayer = $AnimationPlayer

signal fade_finished

func fade_start():
	animationPlayer.play("Fade_to_black")
	
func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("fade_finished")
