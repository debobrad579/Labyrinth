extends Area2D

# I have changed it to use a list!!
# This means that multiple players can be tracked at once.
# If the player enters, they are added to the list/array
# When they exit, they are removed.
# The monster can_see_player whenever the list has contents (i.e. at least one person)
var players = []

func can_see_player():
	return players != []

func _on_PlayerDetection_body_entered(body):
	players.append(body)

func _on_PlayerDetection_body_exited(body):
	players.erase(body)
