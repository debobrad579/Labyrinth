extends Area2D

var invincable = false setget set_invincable

onready var timer = $Timer
onready var Collision = $CollisionShape2D

signal invincability_started
signal invincability_ended

func set_invincable(value):
	invincable = value
	if invincable == true:
		emit_signal("invincability_started")
	else:
		emit_signal("invincability_ended")
		
func start_invincability(duration):
	self.invincable = true
	timer.start(duration)
	
func _on_Timer_timeout():
	self.invincable = false

func _on_Hurtbox_invincability_started():
	Collision.set_deferred("disabled", true)
	
func _on_Hurtbox_invincability_ended():
	Collision.disabled = false
