extends Node2D

# I only index it like this in case I want to sp
var index = {
	"cozy":0,
	"inn":1,
	"shabby":2,
	"straw":3,
	"tavern":4,
	"tall_wall":5,
	"wall":6
}
var buildings = [
	preload("res://game/scenes/map/cozyhome/cozyhome.tscn"),
	preload("res://game/scenes/map/inn/inn.tscn"),
	preload("res://game/scenes/map/shabbyhome/shabbyhome.tscn"),
	preload("res://game/scenes/map/strawhouse/strawhouse.tscn"),
	preload("res://game/scenes/map/tavern/tavern.tscn"),
	preload("res://game/scenes/map/tall_wall/tall_wall.tscn"),
	preload("res://game/scenes/map/wall/wall.tscn")
]

var building_queue = []
var doors = []
var last_building = null

func get_left_edge(building):
	return building.get_node("left_edge").get_pos() + building.get_pos()
func get_right_edge(building):
	return building.get_node("right_edge").get_pos() + building.get_pos()
func get_door_pos(building):
	if building.has_node("door"):
		return building.get_node("door").get_pos()
	else:
		return null

var last_r = -1
func add_building():
	var r = randi()%buildings.size()
	var attempts = 0
	while r == last_r and attempts < 20:
		r = randi()%buildings.size()
		attempts += 1
	last_r = r
	
	var building = buildings[r].instance()
	
	var last_right = Vector2(0, 0)
	if last_building != null:
		last_right = get_right_edge(last_building)
	var new_left = get_left_edge(building)
	building.set_pos(last_right - new_left)
	
	building_queue.push_back(building)
	last_building = building_queue.back()
	var door_pos = get_door_pos(building)
	if door_pos != null:
		doors.push_back(door_pos)
	
	add_child(building)

func check_for_expansion():
	var view_width = int(get_viewport().get_rect().size.width)
	var view_org = int(-get_viewport_transform().get_origin().x)
	var target_x = view_org + view_width * 1.25
	while get_right_edge(last_building).x < target_x:
		add_building()

func _process(delta):
	check_for_expansion()

func _ready():
	randomize()
	add_building()
	check_for_expansion()
	set_process(true)
