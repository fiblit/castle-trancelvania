extends RigidBody2D

var bullet_scene = preload("res://game/bullet.tscn")
onready var root = get_tree().get_root().get_node("level")
onready var player = root.get_node("player")

export var health = 2
export var max_speed = 100
export var fire_rate = 1
export var bullet_range = 300
export var bullet_speed = 250
onready var time_to_shoot = 0

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
		root.spawn_bullet(dir, offset_pos, bullet_range, bullet_speed)

func _process(delta):
	hunt(delta)

func _ready():
	set_process(true)

# duck function that handles stuff when this gets hit by a bullet/projectile
func bullet_hit(bullet):
	health -= 1
	if health <= 0:
		queue_free()

func get_size():
	return get_node("sprite").get_texture().get_size()

#This is so I can spawn bullets in world coordinates! Also, just treat all
#things in world coordinates. Like hunting the player down.
func get_pos():
	return .get_pos() + get_parent().get_pos()
