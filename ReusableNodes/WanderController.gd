extends Node2D

export(int) var WANDER_RANGE = 32
export var GROUNDED = false

onready var startPosition = global_position
onready var targetPosition = global_position
onready var timer = $Timer

func get_time_left():
	return timer.time_left

func start_wander_timer(duration):
	timer.start(duration)

func update_targetPosition():
	if GROUNDED == false:
		var target_vector = Vector2(rand_range(-WANDER_RANGE, WANDER_RANGE), rand_range(-WANDER_RANGE, WANDER_RANGE))
		targetPosition = startPosition + target_vector
	else:
		var target_vector = Vector2(rand_range(-WANDER_RANGE, WANDER_RANGE), 0)
		targetPosition = startPosition + target_vector

func _on_Timer_timeout():
	update_targetPosition()
	
	# This is so every second, the enemy has a new position that it will wander to
	# if it is in the wander state.
