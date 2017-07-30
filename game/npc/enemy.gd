extends RigidBody2D

var bullet_gd = preload("res://game/bullet.gd")
var player = null
export var health = 2
export var max_speed = 150

func hunt():
	if player != null:
		var dir = player.get_pos() - (get_pos() + get_parent().get_pos())
		set_linear_velocity(dir.normalized() * max_speed)
	else:
		player = get_tree().get_root().get_node("level/player")

func _process(delta):
	hunt()

func _ready():
	player = get_tree().get_root().get_node("level/player")
	set_process(true)

func bullet_hit():
	health -= 1
	if health <= 0:
		queue_free()
