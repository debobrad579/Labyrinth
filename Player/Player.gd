extends KinematicBody2D

# Export Constants
export var ACCELERATION = 500
export var MAX_SPEED = 90
export var GRAVITY = 300
export var JUMP_FORCE = 128
export var FRICTION = 675
export var AIR_RESISTANCE = 150
export var WALL_SLIDE_ACCELERATION = 2
export var MAX_WALL_SLIDE_SPEED = 30
export var DOUBLE_JUMP_TOTAL = 1

# Preload Nodes
onready var coyoteTimer = $CoyoteTimer
onready var moveTimer = $WallJumpTimer
onready var wallChecker = $WallChecker
onready var LfloorDetector = $LeftFloorDetector
onready var RfloorDetector = $RightFloorDetector

# Player Platforming Variables
var motion = Vector2.ZERO
var on_floor = false
var on_wall = false
var can_move = true
var wall_jump = false
var double_jump = DOUBLE_JUMP_TOTAL
var wall_double_jump = true
var can_resist = false

func floor_detected():
	if is_on_floor() or LfloorDetector.is_colliding() or RfloorDetector.is_colliding():
		return(true)
	else:
		return(false)
	
# Main physics and process function
func _physics_process(delta):
	
	# Set the horizontal input
	var x_input = Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")
	
	# If there is horizontal input
	# Changed so that player cannot move "up walls" aka really steep slopes
	if x_input != 0 and can_move == true and not is_on_wall():
		
		# Accelerate horizontally, clamp to max speed
		motion.x += x_input * ACCELERATION * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
	
	# NOTE: -------------------------------------------------------------------
	# I used the is_on_floor() function instead of the on_floor bool because it
	# works better with the is_on_wall() variable... this way the player can't
	# jump up high slopes. I also check if the coyote timer is out of time, so
	# this implements the same functionality, just more efficiently.
	# Finally, I removed the "jump" boolean and just set on_floor = false, which
	# is now used to detect coyote time. --------------------------------------
	
	# If is on floor, then set on floor to true.
	if floor_detected() == true: on_floor = true
	
	# If player is on floor and the coyote timer is not stopped,
	if floor_detected() == true or not coyoteTimer.is_stopped():
		
		ACCELERATION = 500
		

		# Wall jump is reset when on floor
		wall_double_jump = true
		double_jump = DOUBLE_JUMP_TOTAL
		
		# If there is not horizonal input (and on floor)
		if x_input == 0:
			
			# 'Decelerate' horizontal motion by friciton
			# NOTE: -----------------------------------------------------------
			#move_toward just moves the value towards another value (in
			# this case 0) by a set amount (continuously adds or subtracts to
			# do so). Its very similar to the lerp function, however its
			# actually more like the when we accelerate x. -------------------
			motion.x = move_toward(motion.x, 0, FRICTION * delta)
		
		# If jump is pressed (and on floor)
		if Input.is_action_just_pressed("jump"):
			
			# Set y velocity/motion to jump force (up) and on_floor to false.
			motion.y = -JUMP_FORCE
			on_floor = false

	# If play is not on floor,
	else:
		
		# If they were JUST on the floor,
		if on_floor == true:
			
			# Start the coyote timer!
			coyoteTimer.start()
			# Then indicate, they are no longer on the floor, so the coyote
			# timer is not reset again.
			on_floor = false
		
		# If jump is released too soon, cut jump force by half (only if jump force
		# Exceeds half value, though).
		if Input.is_action_just_released("jump") and motion.y < -JUMP_FORCE/2 and wall_jump == false:
			motion.y = -JUMP_FORCE/2
		
		# If no horizontal input,
		if x_input == 0:
			
			# Air friction
			motion.x = move_toward(motion.x, 0, AIR_RESISTANCE * delta)
			
		# If there are still double jumps left and they press jump
		if double_jump > 0 and Input.is_action_just_pressed("jump") and not on_wall:
			
			ACCELERATION = 500
			
			# Jump
			motion.y = -JUMP_FORCE
			# Simplified max speed affector
			motion.x = (MAX_SPEED * x_input) / 2
			motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
			
			# After jump is complete, player can move again
			can_move = true
			
			# reduce double jumps by 1
			double_jump -= 1
			if double_jump < 0: double_jump = 0
	
	# If on wall and not on floor (air wall)
	if on_wall and floor_detected() == false:
		
		# If jump is pressed and the player is pressing a key.
		if Input.is_action_just_pressed("jump") and x_input != 0:
			
			AIR_RESISTANCE = 70
			
			# Determine what wall side the player is on
			var wall_side
			
			# Use RayCast to check if wall is on right. Otherwise left
			if wallChecker.is_colliding():
				wall_side = 1
			else:
				wall_side = -1
			
			# Add jump force
			motion.y = -JUMP_FORCE
			# Add velocity based on what wall you are on
			motion.x = MAX_SPEED * -wall_side
			# Turn of movement
			can_move = false
			# Indicate a wall jump has occured
			wall_jump = true
			# Disable movement temporarily
			moveTimer.start()
			
			# Secondary double jump
			if wall_double_jump == true and double_jump == 0:
				double_jump = DOUBLE_JUMP_TOTAL
				wall_double_jump = false
		
		# Wall scaling (only if moving into it)
		if motion.y >= 0 and x_input != 0:
			motion.y = min(motion.y + WALL_SLIDE_ACCELERATION, MAX_WALL_SLIDE_SPEED)
	
	
	var gravity_vector = Vector2(0, GRAVITY)
	motion += gravity_vector * delta
	motion = move_and_slide(motion, -gravity_vector, true, 4, PI/4, false)

func _on_WallDetector_body_entered(body):
	on_wall = true


func _on_WallDetector_body_exited(body):
	on_wall = false


func _on_WallJumpTimer_timeout():
	can_move = true
	AIR_RESISTANCE = 250
	ACCELERATION = 200
