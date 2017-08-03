extends YSort

onready var backdrop = get_node("backdrop")

func get_onscreen_door():
	return backdrop.get_onscreen_door()

func _ready():
	pass
