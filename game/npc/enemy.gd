extends RigidBody2D

var bullet_scene = preload("res://game/bullet.tscn")
var player = null
export var health = 2
export var max_speed = 100
export var fire_rate = 1
export var bullet_range = 600
export var bullet_speed = 300

func find_player():
	if player == null:
		player = get_tree().get_root().get_node("level/player")
	return player != null

var time_to_shoot = 0
func hunt(delta):
	var dir = player.get_pos() - get_pos()
	var ndir = dir.normalized()
	set_linear_velocity(ndir * max_speed)
	
	time_to_shoot -= delta
	if time_to_shoot <= 0:
		var radius = get_size().x * sqrt(2)/2
		var offset_pos = get_pos() + ndir * radius
		spawn_bullet(dir, offset_pos, bullet_range, bullet_speed)
		time_to_shoot = fire_rate

func _process(delta):
	if find_player():
		hunt(delta)

func _ready():
	find_player()
	time_to_shoot = fire_rate
	set_process(true)

func spawn_bullet(dir, pos, dist, speed):
	var bullet = bullet_scene.instance()
	bullet.init(dir, pos, dist, speed)
	get_tree().get_root().add_child(bullet)

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
