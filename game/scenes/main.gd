extends Node2D

var bullet_scene = preload("res://game/bullet.tscn")
export var base_speed = 800

func _input(event):
	var is_press = event.is_pressed()
	var is_echo = event.is_echo()
	var is_valid = is_press and not is_echo
	var is_attack = event.is_action("char_attack")
	if is_valid and is_attack:
		var dir = get_viewport().get_mouse_pos()
		spawn_bullet(dir)

func spawn_bullet(dir):
	dir = dir.normalized() * base_speed
	var node = bullet_scene.instance()
	node.init(dir)
	add_child(node)

func _ready():
	set_process_input(true)
