extends Node2D

export var time_to_spawn = 0.3#seconds
export var size = Vector2(0, 0)
var enemy_scene = preload("res://game/npc/enemy.tscn")

var since_last_spawn = 0
func _process(delta):
	since_last_spawn += delta
	while (since_last_spawn > time_to_spawn):
		since_last_spawn -= time_to_spawn
		spawn_enemy()

func spawn_enemy():
	var x = (randf() + 0.5) * size.width + get_pos().x
	var y = (randf() + 0.5) * size.height + get_pos().y
	
	var enemy = enemy_scene.instance()
	enemy.set_pos(Vector2(x, y))
	get_parent().add_child(enemy)

func _ready():
	randomize() # can also seed if that's desired.
	set_process(true)
