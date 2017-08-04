extends Node2D

export var time_to_spawn = 0.3#seconds
export var size = Vector2(300, 300)
export var capacity = 20
var enemy_scene = preload("res://game/npc/enemy.tscn")
export var e_health = 3#manually copied from enemy.gd
export var e_speed = 100#^^^
export var e_fire_rate = 1#^^^
export var e_bullet_range = 300#^^^
export var e_bullet_speed = 250#^^^

var since_last_spawn = 0
func _process(delta):
	since_last_spawn += delta
	var is_time = since_last_spawn >= time_to_spawn
	var is_full = get_child_count() >= capacity
	while is_time and not is_full:
		spawn_enemy()
		since_last_spawn -= time_to_spawn
		is_time = since_last_spawn >= time_to_spawn
		is_full = get_child_count() >= capacity 
	
	if is_time:
		since_last_spawn -= time_to_spawn

func spawn_enemy():
	var x = (randf()) * size.width
	var y = (randf()) * size.height
	
	var enemy = enemy_scene.instance()
	enemy.set_pos(Vector2(x, y))
	enemy.set_z(y)
	enemy.health = e_health
	enemy.max_speed = e_speed
	enemy.fire_rate = e_fire_rate
	enemy.bullet_range = e_bullet_range
	enemy.bullet_speed = e_bullet_speed
	add_child(enemy)

func _ready():
	randomize() # can also seed if that's desired.
	set_process(true)
