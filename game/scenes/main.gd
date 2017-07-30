extends Node2D

const bullet_scene = preload("res://game/bullet.tscn")
const enemy_scene = preload("res://game/npc/enemy.tscn")
const player_scene = preload("res://game/player/player.tscn")
var player = null
var screen_width = 0
var screen_height = 0
var screen_center = Vector2(0, 0)

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
		var radius = (player.get_size().x) * sqrt(2) / 2
		dir = dir - pos
		spawn_bullet(dir, pos + dir.normalized() * radius)

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
	var bullet = bullet_scene.instance()
	bullet.init(dir, pos)
	add_child(bullet)

func spawn_player():
	player = player_scene.instance()
	var center_x = screen_center.x - player.get_size().width / 2
	var center_y = screen_center.y - player.get_size().height / 2
	player.set_pos(Vector2(center_x, center_y))
	add_child(player)

func spawn_enemy_area():
	pass

func _ready():
	set_process_input(true)
	screen_width = get_viewport_rect().size.width
	screen_height = get_viewport_rect().size.height
	screen_center = Vector2(screen_width / 2, screen_height / 2)
	
	spawn_player()
	spawn_enemy_area()
