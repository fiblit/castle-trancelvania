extends Node2D

export var time_to_spawn = 4#seconds
export var size = Vector2(64, 64)
export var capacity = 6
var e_scene = preload("res://game/scenes/map/chicken/chicken.tscn")
export var e_health = 1
export var e_speed = 200

var since_last_spawn = 0
func _process(delta):
	since_last_spawn += delta
	var is_time = since_last_spawn >= time_to_spawn
	var is_full = get_child_count() >= capacity
	while is_time and not is_full:
		spawn_entity()
		since_last_spawn -= time_to_spawn
		is_time = since_last_spawn >= time_to_spawn
		is_full = get_child_count() >= capacity 
	
	if is_time:
		since_last_spawn -= time_to_spawn

func spawn_entity():
	var x = (randf()) * size.width
	var y = (randf()) * size.height
	
	var e = e_scene.instance()
	e.set_pos(Vector2(x, y))
	e.set_z(y)
	e.health = e_health
	e.max_speed = e_speed
	add_child(e)

func _ready():
	randomize() # can also seed if that's desired.
	set_process(true)
