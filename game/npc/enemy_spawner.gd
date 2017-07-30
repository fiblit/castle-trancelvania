extends Node2D

export var time_to_spawn = 0.3#seconds
export var size = Vector2(0, 0)
export var capacity = 20
var enemy_scene = preload("res://game/npc/enemy.tscn")

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
	var x = (randf() + 0.5) * size.width
	var y = (randf() + 0.5) * size.height
	
	var enemy = enemy_scene.instance()
	enemy.set_pos(Vector2(x, y))
	add_child(enemy)

func _ready():
	randomize() # can also seed if that's desired.
	set_process(true)
