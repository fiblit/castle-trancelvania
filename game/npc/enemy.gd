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
	set_linear_velocity(ndir * max_speed)
	
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
	return get_node("body").get_texture().get_size()

func bullet_hit(bullet):
	bullet.die_on_hit = false

#This is so I can spawn bullets in world coordinates! Also, just treat all
#things in world coordinates. Like hunting the player down.
func get_pos():
	return .get_pos() + get_parent().get_pos()
