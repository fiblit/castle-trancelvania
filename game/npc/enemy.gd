extends RigidBody2D

var bullet_scene = preload("res://game/bullet.tscn")
onready var root = get_tree().get_root().get_node("level")
onready var player = root.player

export var health = 3
export var max_speed = 100
export var fire_rate = 1
export var bullet_range = 300
export var bullet_speed = 250
onready var time_to_shoot = 0

var velocity = Vector2(0, 0)
var pos = Vector2(0, 0)

func hunt(delta):
	var dir = player.get_pos() - get_pos()
	var ndir = dir.normalized()
	var vel = ndir * max_speed
	set_linear_velocity(vel)
	var dom_x = abs(vel.x) > abs(vel.y)
	if dom_x and vel.x > 0:
		get_node("body").set_animation("right_walk")
	elif dom_x and vel.x < 0:
		get_node("body").set_animation("left_walk")
	elif not dom_x and vel.y > 0:
		get_node("body").set_animation("down_walk")
	elif not dom_x and vel.y < 0:
		get_node("body").set_animation("up_walk")
	
	time_to_shoot -= delta
	if time_to_shoot <= 0:
		time_to_shoot = fire_rate
		var radius = get_size().x * sqrt(2)/2
		var offset_pos = get_pos() + ndir * radius
		var root = get_tree().get_root().get_node("level")
		root.spawn_bullet(dir, offset_pos, bullet_range, bullet_speed, "enemy")

func _process(delta):
	player = root.player
	hunt(delta)
	set_z(get_pos().y)

func _ready():
	set_process(true)

func get_size():
	var s = get_node("body")
	var frames = s.get_sprite_frames()
	var frame = frames.get_frame(s.get_animation(), s.get_frame())
	return frame.get_size()

func bullet_hit(bullet):
	bullet.die_on_hit = false

#This is so I can spawn bullets in world coordinates! Also, just treat all
#things in world coordinates. Like hunting the player down.
func get_pos():
	return .get_pos() + get_parent().get_pos()
