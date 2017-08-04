extends YSort

#Note to future self: it's probably best to outsource all of the gen/fill
#functions to the asset's scripts. At least for the sake of extensibility and
#readability. This script has just gotten massive and hard to follow, and
#adding a single asset is confusing and time-consuming.
#Maybe I should've written, rgen and fill funcs in module scenes?

#Speaking of time, I think the Godot editor is so-so quality. The auto-complete
#is currently the main reason I use it since I don't know GDScript well.
#It has poor functionality with everything else for an editor
#The debugger also has very poor UX/UI, I'd like to be able to split panes.
#Swapping between the remote inspector and the continue button is a pain.

#Note to future self: I'm not sure if it was at all a smart idea to split up the
# idea of generating and filling......... -_- At the time I did that I thought
# it was a good idea because it helped to deal with overlap/other abstract vals

var sections_filled = 0
var sections_gened = 0
onready var map = get_parent()
onready var ground = get_node("ground")
onready var tile_set = ground.get_tileset()
onready var tile_size = ground.get_cell_size()
export var section_size = 50
export var terrain_height = 26
export var building_buffer = 0
export var fence_buffer = 3

### module generation
var module = [
	"grass_mound",#(pos (rounds), size, rng)
	"dirt_mound",#(pos (rounds), size, rng)
	# the cobbles are so different, I thought it's best to seperate them...
	"cobble1_mound",#(pos (rounds), size, rng)
	"cobble2_mound",#(pos (rounds), size, rng)
	"barrel",#(pos)
	"enemies",#(pos, size, cap, timer, def: health, speed, rate, brange, bspeed)
	"cows",#(pos, size, cap, timer, def: health, speed)
	"chickens",#(pos, size, cap, timer, def: health, speed)
	"fence",#(pos, length)
	"wall",#(pos, length, rngtall)
	"rock",#(pos)
	"rock_pile",#(pos, size, rng)
]
var to_instance = [
	#["module_name", [params...]],
	#["section", idx],
	#...repeat...
]

func module_gen(section_start, num):
	var sect_idx = section_start / section_size
	for sect in range(0, num):
		var tile_inc = sect * section_size
		var cur_idx = sect_idx + sect
		print("s_gen:", cur_idx, "tile:", section_start + tile_inc)
		
		var start = section_start + tile_inc
		var end = section_start + tile_inc + section_size
		
		var base_pos = Vector2(start, terrain_height - 1)
		base_pos.x *= tile_size.x
		base_pos.y *= tile_size.y
		var mod_base = ["fence", [base_pos, end - start]]
		to_instance.push_back(mod_base)
		
		var breadth = [start, end]
		
		#normally I'd probably make a function out of this, but I don't know how
		#to make a lambda/functor/first-class function in Godot.
		var n = 1 #randi()%(max - min) + min
		for i in range(n):
			rgen_grass_mound(breadth)
		n = 1 #randi()%(max - min) + min
		for i in range(n):
			rgen_dirt_mound(breadth)
		n = 1 #randi()%(max - min) + min
		for i in range(n):
			rgen_barrel(breadth)
		n = 1 #randi()%(max - min) + min
		for i in range(n):
			rgen_enemies(breadth)
		n = 1 #randi()%(max - min) + min
		for i in range(n):
			rgen_cows(breadth)
		n = 1 #randi()%(max - min) + min
		for i in range(n):
			rgen_chickens(breadth)
		n = 1 #randi()%(max - min) + min
		for i in range(n):
			rgen_fence(breadth)
		n = 1 #randi()%(max - min) + min
		for i in range(n):
			rgen_wall(breadth)
		n = 1 #randi()%(max - min) + min
		for i in range(n):
			rgen_rock(breadth)
		n = 1 #randi()%(max - min) + min
		for i in range(n):
			rgen_rock_pile(breadth)
		
		to_instance.push_back(["section", cur_idx])

func r_pos(breadth, size):
	var minx = breadth[0] * tile_size.x
	var maxx = breadth[1] * tile_size.x
	var miny = 0
	var maxy = terrain_height * tile_size.y
	var x = randf() * (maxx - size.x - minx) + minx
	var y = randf() * (maxy - size.y - miny) + miny
	return Vector2(x, y)

func rgen_mound(breadth):
	var sx = (randi()%9 + 1) * tile_size.x
	var sy = (randi()%9 + 1) * tile_size.y
	var pos = r_pos(breadth, Vector2(sx, sy))
	var rng = randi()%50 + 50
	return [pos, Vector2(sx, sy), rng]
func rgen_grass_mound(breadth):
	to_instance.push_back(["grass_mound", rgen_mound(breadth)])
func rgen_dirt_mound(breadth):
	to_instance.push_back(["dirt_mound", rgen_mound(breadth)])
func rgen_cobble1_mound(breadth):
	to_instance.push_back(["cobble1_mound", rgen_mound(breadth)])
func rgen_cobble2_mound(breadth):
	to_instance.push_back(["cobble2_mound", rgen_mound(breadth)])
func rgen_barrel(breadth):
	var pos = r_pos(breadth, Vector2(0, 0))
	to_instance.push_back(["barrel",[pos]])
	
var enemy_settings = {
	"default":[null, Vector2(128, 128), 20, 0.3, 3, 100, 1,   300, 250],
	"speedy":[null,  Vector2(32, 32),   5,  2, 1, 200, 0.1, 600, 50],
	"stupid":[null,  Vector2(256, 256), 40, 0.1, 2, 50,  1.5, 300, 150],
}
func rgen_enemies(breadth):
	var setting = randi()%100
	if setting < 50:
		setting = enemy_settings["default"]
	elif setting < 80:
		setting = enemy_settings["stupid"]
	else:
		setting = enemy_settings["speedy"]
	
	setting[0] = r_pos(breadth, setting[1])
	
	to_instance.push_back(["enemies", setting])

func rgen_cows(breadth):
	var size = Vector2(96, 96)
	var pos = r_pos(breadth, size)
	var default = [pos, size, 2, 4, 3, 25]
	to_instance.push_back(["cows", default])
func rgen_chickens(breadth):
	var size = Vector2(64, 64)
	var pos = r_pos(breadth, size)
	var default = [pos, size, 6, 4, 1, 50]
	to_instance.push_back(["chickens", default])

func rgen_fence(breadth):
	var len = randi()%9 + 1
	var pos = r_pos(breadth, Vector2(len * tile_size.x, 0))
	to_instance.push_back(["fence", [pos, len]])
func rgen_wall(breadth):
	var len = randi()%9 + 1
	var pos = r_pos(breadth, Vector2(len * tile_size.x, 0))
	var rng = randi()%30 + 10
	to_instance.push_back(["wall", [pos, len, rng]])

func rgen_rock(breadth):
	var pos = r_pos(breadth, Vector2(0, 0))
	to_instance.push_back(["rock", [pos]])
func rgen_rock_pile(breadth):
	var mound = rgen_mound(breadth)
	mound[2] -= 45
	to_instance.push_back(["barrel", mound])

### module filling
func module_fill(section_start, num):
	while num > 0 and to_instance.size() > 0:
		var module = to_instance[0][0]
		var params = to_instance[0][1]
		print("[",module,":",params,"]")
		if module == "section":
			num -= 1
		
		elif module == "grass_mound":
			fill_grass_mound(params[0], params[1], params[2])
		elif module == "dirt_mound":
			fill_dirt_mound(params[0], params[1], params[2])
		elif module == "cobble1_mound":
			fill_cobble1_mound(params[0], params[1], params[2])
		elif module == "cobble2_mound":
			fill_cobble2_mound(params[0], params[1], params[2])
		elif module == "barrel":
			fill_barrel(params[0])
		elif module == "enemies":
			if params.size() == 4:
				fill_enemies(params[0], params[1], params[2], params[3])
			else:
				fill_enemies(params[0], params[1], params[2], params[3],
					params[4], params[5], params[6], params[7], params[8])
		elif module == "cows":
			fill_cows(params[0], params[1], params[2], params[3], params[4],
				params[5])
		elif module == "chickens":
			fill_chickens(params[0], params[1], params[2], params[3],
				params[4], params[5])
		elif module == "fence":
			fill_fence(params[0], params[1])
		elif module == "wall":
			fill_wall(params[0], params[1], params[2])
		elif module == "rock":
			fill_rock(params[0])
		elif module == "rock_pile":
			fill_rock_pile(params[0], params[1], params[2])
		
		to_instance.pop_front()

func fill_grass_mound(pos, size, rng):
	for x in range(size.x):
		for y in range(size.y):
			fill_tile(pos, x, y, rng, get_grassy_tile())
func fill_dirt_mound(pos, size, rng):
	for x in range(size.x):
		for y in range(size.y):
			fill_tile(pos, x, y, rng, get_dirty_tile())
func fill_cobble1_mound(pos, size, rng):
	for x in range(size.x):
		for y in range(size.y):
			fill_tile(pos, x, y, rng, cobble1)
func fill_cobble2_mound(pos, size, rng):
	for x in range(size.x):
		for y in range(size.y):
			fill_tile(pos, x, y, rng, cobble2)
func fill_tile(pos, off_x, off_y, rng, type):
	if randi()%100 < rng:
		var tile_x = int(pos.x) % int(tile_size.x) + off_x
		var tile_y = int(pos.y) % int(tile_size.y) + off_y
		ground.set_cell(tile_x, tile_y, type)

var barrel_scene = preload("res://game/scenes/map/barrel/barrel.tscn")
func fill_barrel(pos):
	var barrel = barrel_scene.instance()
	barrel.set_pos(pos)
	barrel.set_z(pos.y)
	map.add_child(barrel)

var spawner_scene = preload("res://game/npc/enemy_spawner.tscn")
func def_fill_enemies(pos, size, cap, timer):
	fill_enemies(pos, size, cap, timer, 2, 100, 1, 300, 250)
func fill_enemies(pos, size, cap, timer, health, speed, rate, brange, bspeed):
	var spawner = spawner_scene.instance()
	spawner.time_to_spawn = timer
	spawner.size = size
	spawner.capacity = cap
	spawner.e_health = health
	spawner.e_speed = speed
	spawner.e_fire_rate = rate
	spawner.e_bullet_range = brange
	spawner.e_bullet_speed = bspeed
	spawner.set_pos(pos)
	spawner.set_z(pos.y)
	map.add_child(spawner)

var cow_scene = preload("res://game/scenes/map/cow/cow_spawner.tscn")
func fill_cows(pos, size, cap, timer, health, speed):
	var spawner = cow_scene.instance()
	spawner.time_to_spawn = timer
	spawner.size = size
	spawner.capacity = cap
	spawner.e_health = health
	spawner.e_speed = speed
	spawner.set_pos(pos)
	spawner.set_z(pos.y)
	map.add_child(spawner)
var chick_scene = preload("res://game/scenes/map/chicken/chicken_spawner.tscn")
func fill_chickens(pos, size, cap, timer, health, speed):
	var spawner = chick_scene.instance()
	spawner.time_to_spawn = timer
	spawner.size = size
	spawner.capacity = cap
	spawner.e_health = health
	spawner.e_speed = speed
	spawner.set_pos(pos)
	spawner.set_z(pos.y)
	map.add_child(spawner)

var fence_scene = preload("res://game/scenes/map/fence/fence.tscn")
func fill_fence(pos, len):
	for i in range(0, len):
		var fence = fence_scene.instance()
		var pos_i = pos + Vector2(i * tile_size.x, 0)
		fence.set_pos(pos_i)
		fence.set_z(pos_i.y)
		map.add_child(fence)

var wall_scene = preload("res://game/scenes/map/wall/wall.tscn")
var tall_wall_scene = preload("res://game/scenes/map/tall_wall/tall_wall.tscn")
func fill_wall(pos, len, rngtall):
	for i in range(0, len):
		var wall
		if randi()%100 < rngtall:
			wall = tall_wall_scene.instance()
		else:
			wall = wall_scene.instance()
		var pos_i = pos + Vector2(i * tile_size.x, 0)
		wall.set_pos(pos_i)
		wall.set_z(pos_i.y)
		map.add_child(wall)

var rock_scene = preload("res://game/scenes/map/rock/rock.tscn")
func fill_rock(pos):
	var rock = rock_scene.instance()
	rock.set_pos(pos)
	rock.set_z(pos.y)
	map.add_child(rock)
func fill_rock_pile(pos, size, rng):
	for x in range(size.x):
		for y in range(size.y):
			if randi()%100 < rng:
				fill_rock(pos + Vector2(x, y))

### tile filling
enum tiles {dirt1, dirt2, grass1, grass2, grass3, bush, cobble1, cobble2, wall}

func get_grassy_tile():
	var r = randi()%100
	if r < 10:
		return bush # 10%
	elif r < 40:
		return grass3 # 30%
	elif r < 70:
		return grass2 # 30%
	else:
		return grass1 # 30%
func get_dirty_tile():
	return randi()%(dirt2 - dirt1 + 1) + dirt1
func get_stony_tile():
	return randi()%(cobble2 - cobble1 + 1) + cobble1

#TODO: add taper to provide variation without modules
func tile_fill(section_start, num, taper):
	var section_end = section_start + num * section_size
	for x in range(section_start, section_end):
		var start = -building_buffer
		for y in range(start, start + building_buffer):
			ground.set_cell(x, y, get_dirty_tile())
		start += building_buffer
		for y in range(start, start + terrain_height):
			ground.set_cell(x, y, cobble1)
		start += terrain_height
		for y in range(start, start + fence_buffer):
			ground.set_cell(x, y, get_grassy_tile())
###

### pre-frame
func try_gen():
	var view_org = get_view_org()
	var view_width = get_view_width()
	var buffer = 2 * section_size * tile_size.x
	var threshold = view_org + view_width + buffer
	
	var section_end = sections_gened * section_size
	if section_end * tile_size.x < threshold:
		var gen_at_once = 3
		module_gen(section_end, gen_at_once)
		sections_gened += gen_at_once

func try_fill():
	var view_org = get_view_org()
	var view_width = get_view_width()
	var buffer = 1 * section_size * tile_size.x
	var threshold = view_org + view_width + buffer
	
	var fill_at_once = 1
	var can_fill = sections_filled + fill_at_once < sections_gened
	var section_end = sections_filled * section_size
	if section_end * tile_size.x < threshold and can_fill:
		tile_fill(section_end, fill_at_once, 0.5)
		module_fill(section_end, fill_at_once)
		sections_filled += fill_at_once

#todo: try_unfill -- no seriously, I need the FPS.
func _process(delta):
	try_gen()
	try_fill()
	#try_unfill() #future: store seed if you want to keep same rng

func get_view_org():
	return int(-get_viewport_transform().get_origin().x)
func get_view_width():
	return int(get_viewport().get_rect().size.width)

func _ready():
	randomize()
	var view_width = get_view_width()
	section_size = view_width / tile_size.x
	set_process(true)
