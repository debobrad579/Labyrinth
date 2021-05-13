extends Area2D

var players = []
var player

func can_see_player():
	return players != []

func _on_PlayerDetection_body_entered(body):
	players.append(body)
	player = body

func _on_PlayerDetection_body_exited(body):
	players.erase(body)
	player = null
