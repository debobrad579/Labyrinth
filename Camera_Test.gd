extends RemoteTransform2D

onready var players = get_tree().get_nodes_in_group("Players")

#func _ready():
#
#	print(players)

func _physics_process(delta):

	if len(players) == 1:

		position = players[0].position

	else:

		position = (players[0].position + players[1].position)/2
#
