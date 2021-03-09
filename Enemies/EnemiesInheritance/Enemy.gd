extends KinematicBody2D
class_name Enemy

export var ACCELERATION = 300
export var MAX_SPEED = 30
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4
export(String, "Flying", "Ground") var ENEMY_TYPE
export var GRAVITY = 300


enum {
	IDLE,
	WANDER,
	CHASE
}

var motion = Vector2.ZERO
var knockback = Vector2.ZERO
var state = IDLE

onready var players = get_tree().get_nodes_in_group("Players")
onready var stats = $Stats
onready var playerDetection = $PlayerDetection
onready var hurtbox = $Hurtbox
onready var wanderController = $WanderController
onready var objectDetector = $ObjectDetector


func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
# This will pick a random state by shuffling the states then picking the first one.


func change_state():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))
# A random state between "IDLE", and "WANDER" is chosen then 
# the timer is reset to a time between 1 and 3 seconds.


func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	if ENEMY_TYPE == "Ground":
		motion.x = motion.move_toward(direction * MAX_SPEED, ACCELERATION * delta).x
	elif ENEMY_TYPE == "Flying":
		motion = motion.move_toward(direction * MAX_SPEED, ACCELERATION * delta)


func target_players_in_sight(player_list : Array = players):
	
	var target_player
	
	if players.size() > 0:
		if players[0] == player_list[0]:
			target_player = players[0]
		elif players[1] == player_list[0]:
			target_player = players[1]
		
	if target_player != null :
		objectDetector.cast_to = target_player.position - position
	
	
	if not objectDetector.is_colliding() and target_player != null:
		return target_player
	else:
		return null


func seek_player():
	if playerDetection.can_see_player():
		if target_players_in_sight(playerDetection.players) != null:
			state = CHASE


func _on_Hurtbox_body_entered(body):
	stats.health -= 1
	if body.knockback_2 == 0:
		knockback = Vector2.RIGHT * 150
	else:
		knockback = Vector2.LEFT * 150


func _on_Stats_no_health():
	queue_free()
