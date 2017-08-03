extends YSort

const bullet_scene = preload("res://game/bullet.tscn")
const enemy_scene = preload("res://game/npc/enemy.tscn")
const player_scene = preload("res://game/player/player.tscn")
var player = null
var screen_width = 0
var screen_height = 0
var screen_center = Vector2(0, 0)

var is_action_held = {
	"char_attack" : false,
	"char_special" : false,
	"char_aim": false,
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

func player_controls(delta):
	var pos = player.get_pos()
	var mouse_pos = get_viewport().get_mouse_pos()
	var view_pos = get_viewport_transform().get_origin()
	var dir_to_mouse = mouse_pos - view_pos - pos
	var ndir_to_mouse = dir_to_mouse.normalized()
	if is_action_held["char_attack"]:
		player.try_fire(ndir_to_mouse, delta)
	
	if is_action_held["char_aim"]:
		player.aim(dir_to_mouse)
	else:
		player.aim(Vector2(0, 0))
	
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

var names = [
	"lim_poirier",
	"da_mciver"
	#"mo_berger",
	#"ah_marlowe"
]
var current_name = null

onready var flee_timer = 0
func try_player_switch(name):
	var is_not_me = current_name != name
	var portrait = "HUD/portrait_" + name
	var is_alive = 0 < get_node(portrait).get_health()
	var fleeing = 0 < flee_timer
	if not fleeing and is_alive and is_not_me:
		switch_to(name)

func switch_to(name):
	var door_pos = get_node("map").get_onscreen_door()
	var old_pos = player.get_pos()
	flee_timer = (door_pos - old_pos).length() / player.max_speed
	player.flee(door_pos)
	spawn_player(name, door_pos)
	var view_org = get_viewport_transform().get_origin()
	player.get_node("tripod").set_pos(old_pos + view_org)
	
	var a = get_active_portrait()
	var n = get_named_portrait()
	a.copy(n)
	player.set_health(n.get_health() / 20)
	player.set_ability(n.get_ability())

func _process(delta):
	player_controls(delta)
	if flee_timer > 0:
		flee_timer -= delta
		for name in names:
			var val
			if flee_timer <= 0:
				val = 1
			else:
				val = 0.5
			get_node("HUD/portrait_"+name).set_opacity(val)

func _input(event):
	try_hold_actions(event)
	for name in names:
		if event.is_action_pressed("switch_to_" + name):
			try_player_switch(name)

func spawn_player(name, pos):
	current_name = name
	player = load("res://game/player/"+name+".tscn").instance()
	player.set_pos(pos)
	add_child(player)
	player.connect("player_death", self, "on_player_death")

func _ready():
	set_process_input(true)
	set_process(true)
	screen_width = get_viewport_rect().size.width
	screen_height = get_viewport_rect().size.height
	screen_center = Vector2(screen_width / 2, screen_height / 2)
	
	spawn_player(names[0], Vector2(0, 32 * 14))

func spawn_bullet(dir, pos, dist, speed):
	var bullet = bullet_scene.instance()
	bullet.init(dir, pos, dist, speed)
	add_child(bullet)

func get_active_portrait():
	return get_node("HUD/portrait_active")

func get_named_portrait():
	return get_node("HUD/portrait_"+current_name)

func on_player_death():
	get_node("/root/scene_changer").goto_scene("res://game/gui/menu/menu.tscn")
