extends YSort
#So I made this a Ysort in the hopes that it would properly YSort with the
#player... It didn't. Not sure what I was doing wrong.

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
var left_offscreen = -1
var left_onscreen = 0 #maintained as 1 more than offscreen
var right_offscreen = 1
var right_onscreen = 0 #maintained as 1 less than offscreen

var last_building = null

func get_left_edge(building):
	return building.get_node("left_edge").get_pos() + building.get_pos()
func get_right_edge(building):
	return building.get_node("right_edge").get_pos() + building.get_pos()
func get_door_pos(building):
	if building.has_node("door"):
		return building.get_node("door").get_pos() + building.get_pos()
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
	building.set_z((last_right - new_left).y)
	
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

func update_doors():
	var view_width = int(get_viewport().get_rect().size.width)
	var view_org = int(-get_viewport_transform().get_origin().x)
	var l_edge = view_org
	var r_edge = view_org + view_width
	
	# can't make this a function because int can only pass by value
	var l_off = doors[left_offscreen].x
	var l_on = doors[left_onscreen].x
	if l_on < l_edge and left_onscreen < doors.size() - 1:
		left_offscreen += 1
		left_onscreen += 1
	if l_off > l_edge and left_offscreen > 0:
		left_offscreen -= 1
		left_onscreen -= 1
		
	var r_off = doors[right_offscreen].x
	var r_on = doors[right_onscreen].x
	if r_off < r_edge and right_offscreen < doors.size() - 1:
		right_offscreen += 1
		right_onscreen += 1
	if r_on > r_edge and right_onscreen > 0:
		right_offscreen -= 1
		right_onscreen -= 1


func get_onscreen_door():
	return doors[randi()%(right_onscreen - left_onscreen) + left_onscreen]

func _process(delta):
	check_for_expansion()
	update_doors()

func _ready():
	randomize()
	add_building()
	check_for_expansion()
	set_process(true)
