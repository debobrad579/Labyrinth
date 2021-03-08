class_name DefaultEnemy
extends KinematicBody2D

onready var players = get_tree().get_nodes_in_group("Players")
onready var objectDetector = $ObjectDetector

func target_player_in_sight(player_list : Array = players):
	
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
