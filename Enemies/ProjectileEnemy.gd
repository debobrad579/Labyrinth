extends "res://Enemies/EnemiesInheritance/Enemy.gd"

const EnemyBullet = preload("res://Enemies/EnemyProjectile.tscn")

export var SPREAD = 30

onready var fireDirection = $FireDirection
onready var firePosition = $FirePosition

func fire_bullet():
	var bullet = Utils.instance_scene_on_main(EnemyBullet, firePosition.global_position)
	bullet.SPEED *= rand_range(1, 2)
	bullet.motion = (fireDirection.global_position - global_position).normalized() * bullet.SPEED
	bullet.motion = bullet.motion.rotated(deg2rad(rand_range(-SPREAD/2, SPREAD/2)))
