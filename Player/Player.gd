extends KinematicBody2D

export var player_id = 0 

# Input map variables
var LEFT
var RIGHT
var UP
var DOWN
var JUMP
var DASH
var ATTACK
var SECONDARY_ATTACK

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
	else:
		LEFT = ""
		RIGHT = ""
		UP = ""
		DOWN = ""
		JUMP = ""
		DASH = ""
		ATTACK = ""
		SECONDARY_ATTACK = ""

# States
enum {
	MOVE,
	WALL_SLIDE
}

# Export Constants
export var ACCELERATION = 512
export var MAX_SPEED = 90
export var FRICTION = 0.25
export var AIR_RESISTANCE = 0.02
export var GRAVITY = 200
export var JUMP_FORCE = 128
export var MAX_SLOPE_ANGLE = 46
export var BULLET_SPEED = 250
export var MISSILE_SPEED = 150
export var WALL_SLIDE_SPEED = 38
export var MAX_WALL_SLIDE_SPEED = 100
export var WALL_JUMP_RESISTANCE = 0.02
export var CLIMB_MAX_SPEED = 50
export var CLIMB_SPEED = 60
export var CLIMB_DOWN_SPEED = 40
export var CLIMB_ACCELERATION = 0.1
export var MANA_REGENERATION_SPEED = 0.25

# Preload Scenes
const MAGIC_PROJECTILE = preload("res://Player/MagicProjectile.tscn")

# Preload Nodes
onready var coyoteTimer = $CoyoteTimer
onready var wallJumpTimer = $WallJumpTimer
onready var attackTimer = $AttackTimer
onready var dashTimer = $DashTimer
onready var jumpTimer = $JumpTimer
onready var LladderDetector = $LeftLadderDetector
onready var RladderDetector = $RightLadderDetector
onready var attackPivot = $BasicAttackPivot
onready var attack_hitbox = $BasicAttackPivot/BasicAttack/CollisionShape2D
onready var attack_hitbox2 = $BasicAttackPivot/BasicAttack
onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var projectileSummoner = $ProjectileSummoner

# Variables
var state = MOVE
var direction_facing = Vector2(1, 0)
var motion = Vector2.ZERO
var snap_vector = Vector2.ZERO
var projectile_summoner_offset
var just_jumped = false
var just_wall_jumped = false
var double_jump = true
var jumping = false
var climbing = false
var climbing_down = false
var wall_double_jump = true
var wall_jump_axis = 1

func _ready():
	change_player_id(player_id)
	add_to_group("Players", true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	projectile_summoner_offset = projectileSummoner.position.x

func _physics_process(delta):
	just_jumped = false
	
	set_direction_facing()
	set_mana_regeneration(delta)
	
	match state:
		MOVE:
			var input_vector = get_input_vector()
			apply_horizontal_force(input_vector, delta)
			apply_friction(input_vector)
			update_snap_vector()
			jump_check(input_vector)
			ladder_check()
			apply_gravity(delta)
			move()
			wall_slide_check()
			
		WALL_SLIDE:
			var wall_axis = get_wall_axis()
			wall_jump_check(wall_axis)
			wall_slide_descending_speed_check(delta)
			ladder_check()
			move()
			wall_detach_check(wall_axis, delta)
			
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
	if Input.is_action_just_pressed(ATTACK):
		create_regular_attack()
		
	if Input.is_action_just_pressed(SECONDARY_ATTACK) and stats.mana >= 2:
		create_mana_attack()
		
func create_regular_attack():
	set_attack_pivot_rotation()
	attack_hitbox.disabled = false
	attackTimer.start()
	
func set_attack_pivot_rotation():
	if direction_facing.x == 1:
		attackPivot.rotation_degrees = 0
	else:
		attackPivot.rotation_degrees = 180
		
func set_mana_regeneration(delta):
	if stats.mana < stats.maxMana:
		(stats.mana = move_toward(stats.mana, stats.maxMana, 
		MANA_REGENERATION_SPEED * delta))
	else:
		stats.mana = stats.maxMana
		
func create_mana_attack():
	set_projectile_summoner_position()
	stats.mana -= 2
	var magic_projectile = MAGIC_PROJECTILE.instance()
	get_parent().add_child(magic_projectile)
	magic_projectile.knockback_2 = attack_hitbox2.knockback_2
	magic_projectile.position = projectileSummoner.global_position
	
func set_projectile_summoner_position():
	if direction_facing.y == 0:
		projectileSummoner.position.y = 0
		projectileSummoner.position.x = projectile_summoner_offset * direction_facing.x
	else:
		projectileSummoner.position.x = 0
		projectileSummoner.position.y = projectile_summoner_offset * direction_facing.y
		
# This function will definitely be changed.
func set_direction_facing():
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

func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength(RIGHT) - Input.get_action_strength(LEFT)
	return input_vector
	
func apply_horizontal_force(input_vector, delta):
	if input_vector.x != 0 and just_wall_jumped == false:
		motion.x += ACCELERATION * input_vector.x * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		
	# After a wall jump
	if just_wall_jumped and input_vector.x == wall_jump_axis:
		motion.x = lerp(motion.x, MAX_SPEED * input_vector.x, WALL_JUMP_RESISTANCE)
	elif just_wall_jumped and input_vector.x != wall_jump_axis:
		motion.x += ACCELERATION * input_vector.x * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
	
	# While climbing
	if climbing:
		motion.x = clamp(motion.x, -CLIMB_MAX_SPEED, CLIMB_MAX_SPEED)
		
func apply_friction(input_vector):
	if input_vector.x != 0: return
	
	if is_on_floor():
		motion.x = lerp(motion.x, 0, FRICTION)
	else:
		motion.x = lerp(motion.x, 0, AIR_RESISTANCE)
		
	if climbing:
		motion.x = lerp(motion.x, 0, FRICTION)
			
func apply_gravity(delta):
	if not is_on_floor():
		motion.y += GRAVITY * delta
		motion.y = min(motion.y, JUMP_FORCE)
		if motion.y > 0:
			jumping = false
			
func update_snap_vector(): if is_on_floor(): snap_vector = Vector2.DOWN

func jump_check(input_vector):
	if is_on_floor():
		if Input.is_action_just_pressed(JUMP):
			jump(JUMP_FORCE)
			just_jumped = true
			
		if jumpTimer.is_stopped(): return
		
		if Input.is_action_pressed(JUMP): jump(JUMP_FORCE)
		else: jump(JUMP_FORCE/2)
		
		just_jumped = true
		return
		
	if not Input.is_action_just_pressed(JUMP):
		jump_released_check()
		return
		
	if double_jump:
		just_wall_jumped = false
		motion.x = input_vector.x * MAX_SPEED
		
	if not coyoteTimer.is_stopped():
		jump(JUMP_FORCE)
		
	else:
		if double_jump:
			jump(JUMP_FORCE * 0.8)
			double_jump = false
	jumpTimer.start()
		
func jump(force):
	jumping = true
	motion.y = -force
	snap_vector = Vector2.ZERO
	
func jump_released_check():
	if Input.is_action_just_released(JUMP) and motion.y < -JUMP_FORCE/2:
		motion.y = -JUMP_FORCE/2
		
func ladder_check():
	if Input.is_action_pressed(UP) and ladder_detected():
		motion.y = -CLIMB_SPEED
		climbing_down = false
		climbing = true
		double_jump = true
		snap_vector = Vector2.ZERO
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
		
func ladder_detected():
	if LladderDetector.is_colliding() or RladderDetector.is_colliding():
		return true
		
func move():
	var was_on_floor = is_on_floor()
	var was_in_air = not is_on_floor()
	var last_motion = motion
	var last_position = position
	
	motion = (move_and_slide_with_snap(motion, snap_vector * 4, Vector2.UP, 
	true, 4, deg2rad(MAX_SLOPE_ANGLE)))
	
	# Just landed
	if was_in_air and is_on_floor():
		motion.x = last_motion.x
		double_jump = true
		wall_double_jump = true
		just_wall_jumped = false
		jumping = false
	
	# Just left ground
	if was_on_floor and not is_on_floor() and not just_jumped: 
		motion.y = 0
		position.y = last_position.y
		coyoteTimer.start()

	# Prevent Sliding
	if (is_on_floor() and 
	get_floor_velocity().length() == 0 and abs(motion.x) < 1): 
		position.x = last_position.x

func wall_slide_check():
	if is_on_floor() or not is_on_wall(): return
	state = WALL_SLIDE
	just_wall_jumped = false
	if wall_double_jump == false: return
	if double_jump == false:
		wall_double_jump = false
		double_jump = true
	else:
		double_jump = true
		
# Get_wall_axis will return -1 if there's a wall to the left, 
# 1 if there's a wall to the right, 
# and 0 if there's no wall.
func get_wall_axis():
	var is_wall_right = test_move(transform, Vector2.RIGHT)
	var is_wall_left = test_move(transform, Vector2.LEFT)
	return int(is_wall_right) - int(is_wall_left)
	
func wall_jump_check(wall_axis):
	if Input.is_action_just_pressed(JUMP):
		motion.x = -wall_axis * MAX_SPEED
		motion.y = -JUMP_FORCE / 1.25
		wall_jump_axis = wall_axis
		just_wall_jumped = true
		jumping = true
		wallJumpTimer.start()
		state = MOVE
				
func wall_slide_descending_speed_check(delta):
	var max_slide_speed = WALL_SLIDE_SPEED
	if Input.is_action_pressed(DOWN):
		max_slide_speed = MAX_WALL_SLIDE_SPEED
	motion.y = min(motion.y + GRAVITY * delta, max_slide_speed)
	
func wall_detach_check(wall_axis, delta):
	match wall_axis:
		1:
			if Input.is_action_pressed(LEFT):
				motion.x = -ACCELERATION * delta
				state = MOVE
		-1:
			if Input.is_action_pressed(RIGHT):
				motion.x = ACCELERATION * delta
				state = MOVE
				
	if wall_axis == 0 or is_on_floor():
		state = MOVE

func _on_AttackTimer_timeout():
	attack_hitbox.disabled = true

func _on_Stats_no_health():
	remove_from_group("Players")
	queue_free()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincability(1)
