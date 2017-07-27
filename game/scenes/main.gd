extends Node2D

var bullet_scene = preload("res://game/bullet.tscn")
var player = null

func _input(event):
	if event.is_action_pressed("char_attack"):
		var dir = get_viewport().get_mouse_pos()
		var pos = player.get_pos()
		dir = dir - pos
		spawn_bullet(dir, pos)
	elif event.is_action_pressed("char_move_up"):
		player.move(Vector2(0, -10))
	elif event.is_action_pressed("char_move_down"):
		player.move(Vector2(0, 10))
	elif event.is_action_pressed("char_move_left"):
		player.move(Vector2(-10, 0))
	elif event.is_action_pressed("char_move_right"):
		player.move(Vector2(10, 0))

func spawn_bullet(dir, pos):
	var node = bullet_scene.instance()
	node.init(dir, pos)
	add_child(node)

func _ready():
	player = get_node("Player")
	set_process_input(true)
