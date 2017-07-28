extends Node2D

var bullet_scene = preload("res://game/bullet.tscn")
var player = null

var is_action_held = {
	"char_attack" : false,
	"char_move_up" : false,
	"char_move_down" : false,
	"char_move_left" : false,
	"char_move_right" : false}

func try_hold_actions(event):
	for a in is_action_held.keys():
		if event.is_action_pressed(a):
			is_action_held[a] = true
		elif event.is_action_released(a):
			is_action_held[a] = false

func _input(event):
	try_hold_actions(event)
	
	if event.is_action_pressed("char_attack"):
		var dir = get_viewport().get_mouse_pos()
		var pos = player.get_pos()
		dir = dir - pos
		spawn_bullet(dir, pos)

	var motion = Vector2(0, 0)
	if is_action_held["char_move_up"]:
		motion += Vector2(0, -1)
	if is_action_held["char_move_down"]:
		motion += Vector2(0, 1)
	if is_action_held["char_move_left"]:
		motion += Vector2(-1, 0)
	if is_action_held["char_move_right"]:
		motion += Vector2(1, 0)
	if motion.length_squared() > 0:
		player.accel(motion)
	else:
		player.deccel()

func spawn_bullet(dir, pos):
	var node = bullet_scene.instance()
	node.init(dir, pos)
	add_child(node)

func _ready():
	player = get_node("Player")
	set_process_input(true)
