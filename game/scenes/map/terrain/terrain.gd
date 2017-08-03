extends YSort

var sections_filled = 0
var sections_gened = 0
onready var ground = get_node("ground")
onready var tile_set = ground.get_tileset()
onready var tile_size = ground.get_cell_size()
export var section_size = 50
export var terrain_height = 26
export var building_buffer = 1
export var fence_buffer = 3

### module generation
var module = [
	"grass_mound",#(pos, size, rng)
	"dirt_mound",#(pos, size, rng)
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
	for i in range(0, num):
		var start = section_start + section_size * i
		var end = section_start + section_size * (i + 1)
		var fence = Vector2(start * tile_size.x, (terrain_height - 1) * tile_size.y)
		to_instance.push_back(["fence", [fence, end - start]])
		to_instance.push_back(["section", section_start / section_size + i])

### module filling
func module_fill(section_start, num):
	while num > 0 and to_instance.size() > 0:
		var module = to_instance[0][0]
		var params = to_instance[0][1]
		if module == "section":
			num -= 1
		elif module == "fence":
			fill_fence(params[0], params[1])
		to_instance.pop_front()

func fill_grass_mound(pos):
	pass
func fill_dirt_mound(pos):
	pass

var barrel_scene = preload("res://game/scenes/map/barrel/barrel.tscn")
func fill_barrel(pos):
	pass

var spawner_scene = preload("res://game/npc/enemy_spawner.tscn")
func fill_enemies(pos):
	pass

var cow_scene = preload("res://game/scenes/map/cow/cow.tscn")
func fill_cows(pos):
	pass

var chicken_scene = preload("res://game/scenes/map/chicken/chicken.tscn")
func fill_chickens(pos):
	pass

var fence_scene = preload("res://game/scenes/map/fence/fence.tscn")
func fill_fence(pos, len):
	for i in range(0, len):
		var fence = fence_scene.instance()
		fence.set_pos(pos + Vector2(i * tile_size.x, 0))
		add_child(fence)

var wall_scene = preload("res://game/scenes/map/wall/wall.tscn")
var tall_wall_scene = preload("res://game/scenes/map/tall_wall/tall_wall.tscn")
func fill_wall(pos, len, rngtall):
	pass

var rock_scene = preload("res://game/scenes/map/rock/rock.tscn")
func fill_rock(pos):
	pass
func fill_rock_pile(pos):
	pass

### tile filling
enum tiles {dirt1, dirt2, grass1, grass2, grass3, bush, cobble1, cobble2, wall}

func get_grassy_tile():
	var r = randi()%100
	if r < 10:
		return bush
	elif r < 40:
		return grass3
	elif r < 70:
		return grass2
	else:
		return grass1
func get_dirty_tile():
	return randi()%(dirt2 - dirt1 + 1) + dirt1
func get_stony_tile():
	return randi()%(cobble2 - cobble1 + 1) + cobble1

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
	var threshold = view_org + view_width + 2 * section_size * tile_size.x
	var section_end = sections_gened * section_size
	if section_end * tile_size.x < threshold:
		module_gen(section_end, 3)
		sections_gened += 3

func try_fill():
	var view_org = get_view_org()
	var view_width = get_view_width()
	var threshold = view_org + view_width + section_size * tile_size.x
	var section_end = sections_filled * section_size
	if section_end * tile_size.x < threshold:
		tile_fill(section_end, 2, 0.5)
		module_fill(section_end, 2)
		sections_filled += 2

func _process(delta):
	try_gen()
	try_fill()

func get_view_org():
	return int(-get_viewport_transform().get_origin().x)
func get_view_width():
	return int(get_viewport().get_rect().size.width)

func _ready():
	randomize()
	var view_width = get_view_width()
	section_size = view_width / tile_size.x
	set_process(true)
