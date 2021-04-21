extends KinematicBody2D

# Player id. Note that it is exported, so this value can be 
# Adjusted for Player1 scene and Player2 scene to 0 and 1 respectively.
# See _ready() function below
export var player_id = 0 #0 is player 1... 1 is player 2

# Set up input map variables
var LEFT
var RIGHT
var UP
var DOWN
var JUMP
var DASH
var ATTACK
var SECONDARY_ATTACK

# When the players id is changed, adopt appropriate input map.
# Characteers with an id that is no p1 or p2 would be assigned a blank
# Input map so they do not move.
func change_player_id(id):
	
	player_id = id
	
	if player_id == 0:
		
		LEFT = "walk_left_p1"
		RIGHT = "walk_right_p1"
		UP = "up_p1"
		DOWN = "down_p1"
		JUMP = "jump_p1"
		DASH = "dash_p1"
		ATTACK = "attack_p1"
		SECONDARY_ATTACK = "secondary_attack_p1"
	
	elif player_id == 1:
		
		LEFT = "walk_left_p2"
		RIGHT = "walk_right_p2"
		UP = "up_p2"
		DOWN = "down_p2"
		JUMP = "jump_p2"
		DASH = "dash_p2"
		ATTACK = "attack_p2"
		SECONDARY_ATTACK = "secondary_attack_p2"
	# We will change the button maping for the final game.
		
	else:
		
		LEFT = ""
		RIGHT = ""
		UP = ""
		DOWN = ""
		JUMP = ""
		DASH = ""
		ATTACK = ""
		SECONDARY_ATTACK = ""

# Export Constants
export var ACCELERATION = 500
export var MAX_SPEED = 100
export var WALL_JUMP_SPEED = 90
export var GRAVITY = 300
export var JUMP_FORCE = 128
export var CLIMB_MAX_SPEED = 50
export var CLIMB_SPEED = 60
export var CLIMB_DOWN_SPEED = 40
export var CLIMB_ACCELERATION = 0.1
export var FRICTION = 675
export var AIR_RESISTANCE = 150
export var WALL_SLIDE_ACCELERATION = 2
export var MAX_WALL_SLIDE_SPEED = 30
export var DOUBLE_JUMP_TOTAL = 1
export var MANA_REGENERATION_SPEED = 0.25
export var PROJECTILE_SUMMONER_POSITION_X = 8
export var PROJECTILE_SUMMONER_POSITION_Y = 0

# Preload Scenes
const MAGIC_PROJECTILE = preload("res://Player/MagicProjectile.tscn")

# Preload Nodes
onready var coyoteTimer = $CoyoteTimer
onready var moveTimer = $WallJumpTimer
onready var attackTimer = $AttackTimer
onready var dashTimer = $DashTimer
onready var jumpTimer = $JumpTimer
onready var wallCheckerBottom = $WallCheckerBottom
onready var wallCheckerTop = $WallCheckerTop
onready var LfloorDetector = $LeftFloorDetector
onready var RfloorDetector = $RightFloorDetector
onready var LladderDetector = $LeftLadderDetector
onready var RladderDetector = $RightLadderDetector
onready var attackPivot = $BasicAttackPivot
onready var attack_hitbox = $BasicAttackPivot/BasicAttack/CollisionShape2D
onready var attack_hitbox2 = $BasicAttackPivot/BasicAttack
onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var projectileSummoner = $ProjectileSummoner

# Player Platforming Variables
var motion = Vector2.ZERO
var on_floor = false
var on_wall = false
var can_move = true
var wall_jump = false
var double_jump = DOUBLE_JUMP_TOTAL
var wall_double_jump = true
var jumping = false
var can_resist = false
var direction_facing = Vector2(1, 0)
var dash = false
var climbing = false
var climbing_down = false

signal player_died

# When ready, change the id and input maps to the cooresponding ones.
func _ready():
	change_player_id(player_id)
	add_to_group("Players", true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	projectileSummoner.position.x = PROJECTILE_SUMMONER_POSITION_X
	projectileSummoner.position.y = PROJECTILE_SUMMONER_POSITION_Y
	
func ladder_detected():
	if LladderDetector.is_colliding() or RladderDetector.is_colliding():
		return true

func floor_detected():
	if is_on_floor() or LfloorDetector.is_colliding() or RfloorDetector.is_colliding():
		return(true)
	else:
		return(false)
		
func wall_slide():
	if on_wall and Input.is_action_pressed(RIGHT):
		return true
	else:
		if on_wall and Input.is_action_pressed(LEFT):
			return true
		else:
			return false
	
# Main physics and process function
func _physics_process(delta):
	
	var x_input = Input.get_action_strength(RIGHT) - Input.get_action_strength(LEFT)
	
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	
	if Input.is_action_pressed(LEFT) and not Input.is_action_pressed(RIGHT):
		direction_facing.x = -1
		attack_hitbox2.knockback_2 = 1
	
	if Input.is_action_pressed(RIGHT) and not Input.is_action_pressed(LEFT):
		direction_facing.x = 1
		attack_hitbox2.knockback_2 = 0
		
	if Input.is_action_pressed(UP):
		direction_facing.y = -1
		
	if Input.is_action_pressed(DOWN):
		direction_facing.y = 1
		
	if not Input.is_action_pressed(UP) and not Input.is_action_pressed(DOWN):
		direction_facing.y = 0
		
	if Input.is_action_pressed(UP) and Input.is_action_pressed(DOWN):
		direction_facing.y = 0
	
	if stats.mana < stats.maxMana:
		stats.mana = move_toward(stats.mana, stats.maxMana, MANA_REGENERATION_SPEED * delta)
	else:
		stats.mana = stats.maxMana
	
	if Input.is_action_just_pressed(DASH) and dash == false:
		pass
		
	if ladder_detected():
		on_wall = false
		
	if Input.is_action_pressed(UP) and ladder_detected():
		motion.y = -CLIMB_SPEED
		climbing_down = false
		climbing = true
		double_jump = DOUBLE_JUMP_TOTAL
	elif ladder_detected() and jumping == false:
		climbing = false
		if Input.is_action_pressed(DOWN):
			climbing_down = true
			motion.y = lerp(motion.y, CLIMB_DOWN_SPEED * 3, CLIMB_ACCELERATION)
		else:
			motion.y = lerp(motion.y, CLIMB_DOWN_SPEED, CLIMB_ACCELERATION)
	else:
		climbing = false
		climbing_down = false
	
	if Input.is_action_just_pressed(ATTACK):
		if direction_facing.x == 1:
			attackPivot.rotation_degrees = 0
		else:
			attackPivot.rotation_degrees = 180
		attack_hitbox.disabled = false
		attackTimer.start()
		
	if direction_facing.y == 0:
		projectileSummoner.position.y = PROJECTILE_SUMMONER_POSITION_Y
		projectileSummoner.position.x = PROJECTILE_SUMMONER_POSITION_X * direction_facing.x
	else:
		projectileSummoner.position.x = 0
		projectileSummoner.position.y = PROJECTILE_SUMMONER_POSITION_X * direction_facing.y + 4 * direction_facing.y
	
	if Input.is_action_just_pressed(SECONDARY_ATTACK):
		if stats.mana >= 2:
			stats.mana -= 2
			var magic_projectile = MAGIC_PROJECTILE.instance()
			get_parent().add_child(magic_projectile)
			magic_projectile.knockback_2 = attack_hitbox2.knockback_2
			magic_projectile.position = projectileSummoner.global_position
		
	if Input.is_action_just_released(JUMP) or on_floor == true or motion.y > 0:
		jumping = false
	
	# If they jump slightly before ground contact, they will jump on contact.
	if floor_detected() == false and Input.is_action_just_pressed(JUMP):
		jumpTimer.start()
	
	# If there is horizontal input
	# Changed so that player cannot move "up walls" aka really steep slopes
	if x_input != 0 and can_move == true and not is_on_wall():
		
		# Accelerate horizontally, clamp to max speed
		motion.x += x_input * ACCELERATION * delta
		if climbing == false:
			motion.x = clamp(motion.x, -MAX_SPEED * abs(x_input), MAX_SPEED * abs(x_input))
		else:
			motion.x = clamp(motion.x, -CLIMB_MAX_SPEED * abs(x_input), CLIMB_MAX_SPEED * abs(x_input))
	
	# If is on floor, then set on floor to true.
	if floor_detected() == true: 
		on_floor = true
		if jumpTimer.is_stopped() == false:
			motion.y = -JUMP_FORCE
	
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
		if Input.is_action_just_pressed(JUMP):
			
			# Set y velocity/motion to jump force (up) and on_floor to false.
			motion.y = -JUMP_FORCE
			jumping = true
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
		if Input.is_action_just_released(JUMP) and motion.y < -JUMP_FORCE/2 and wall_jump == false:
			motion.y = -JUMP_FORCE/2
		# If no horizontal input,
		if x_input == 0:
				#Normal friction if by ladder.
			if ladder_detected():
				motion.x = move_toward(motion.x, 0, FRICTION * delta)
			else:
				# Air friction
				motion.x = move_toward(motion.x, 0, AIR_RESISTANCE * delta)
			
		# If there are still double jumps left and they press jump
		if double_jump > 0 and Input.is_action_just_pressed(JUMP) and wall_slide() == false:
			
			ACCELERATION = 500
			if climbing == false:
				# Jump
				motion.y = -JUMP_FORCE
				jumping = true
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
		if Input.is_action_just_pressed(JUMP) and x_input != 0:
			
			AIR_RESISTANCE = 70
			
			# Determine what wall side the player is on
			var wall_side
			
			# Use RayCast to check if wall is on right. Otherwise left
			if wallCheckerBottom.is_colliding() or wallCheckerTop.is_colliding():
				wall_side = 1
			else:
				wall_side = -1
			
			# Add jump force
			motion.y = -JUMP_FORCE
			jumping = true
			# Add velocity based on what wall you are on
			motion.x = WALL_JUMP_SPEED * -wall_side
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
		if motion.y >= 0 and wall_slide():
			motion.y = min(motion.y + WALL_SLIDE_ACCELERATION, MAX_WALL_SLIDE_SPEED)
	
	var gravity_vector = Vector2(0, GRAVITY)
	if not ladder_detected() or Input.is_action_pressed(JUMP):
		motion += gravity_vector * delta
	motion = move_and_slide(motion, -gravity_vector, true, 4, PI/4, false)

func _on_WallDetector_body_entered(_body):
	on_wall = true

func _on_WallDetector_body_exited(_body):
	on_wall = false

func _on_WallJumpTimer_timeout():
	can_move = true
	AIR_RESISTANCE = 250
	ACCELERATION = 200

func _on_AttackTimer_timeout():
	attack_hitbox.disabled = true

func _on_Stats_no_health():
	remove_from_group("Players")
	queue_free()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincability(1)

func _on_DashTimer_timeout():
	dash = false
	MAX_SPEED /= 2
