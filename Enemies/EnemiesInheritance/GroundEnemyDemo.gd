extends GroundEnemy


func _ready():
	state = pick_random_state([IDLE, WANDER])
# Start at a random state.

func _physics_process(delta):
	
	match state:
		IDLE:
			motion = motion.move_toward(Vector2.ZERO, FRICTION * delta)
		# If the enemy was moving, it will slow to a stop.
			seek_player()
		# The enemy searches for the player while in the "IDLE" state.

			if wanderController.get_time_left() == 0:
				change_state()
		WANDER:
			seek_player()
		# The enemy still searches for the player while in the "WANDER" state.

			if wanderController.get_time_left() == 0:
				change_state()
			# After a certain amount of time, the enemy will choose a random state.

			accelerate_towards_point(wanderController.targetPosition, delta)

			if global_position.distance_to(wanderController.targetPosition) <= WANDER_TARGET_RANGE:
				change_state()
		# If the player is not detected and the enemy's "WANDER" state is chosen, the
		# enemy will chose a spot to wander to, then move towards that spot. The enemy
		# will then choose a random state.

		CHASE:
			if playerDetection.can_see_player():
				var player = target_players_in_sight(playerDetection.players)
				if player != null:
					accelerate_towards_point(player.global_position, delta)
					
					if is_on_floor() and is_at_wall():
						jump()
				else:
					state = IDLE
			else:
				state = IDLE
		# The enemy will move towards the player if the player is detected.
				
	var gravity_vector = Vector2(0, GRAVITY)
	motion += gravity_vector * delta
	motion = move_and_slide(motion, -gravity_vector, true, 4, PI/4, false)
	
	if is_at_wall(wall.RIGHT):
		wanderController.startPosition.x = self.position.x - rand_range(16, 64)
		wanderController.startPosition.y = self.position.y
	if is_at_wall(wall.LEFT):
		wanderController.startPosition.x = self.position.x + rand_range(16, 64)
		wanderController.startPosition.y = self.position.y
	# This is so the enemy won't continue trying to stay near the previouse startPosition after
	# falling off a ledge.
