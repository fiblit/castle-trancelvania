extends TextureFrame

func set_health(hp):
	get_node("health_slots").set_val(hp * 20)

func get_health():
	return get_node("health_slots").get_val()

export var on_fire = false
func set_ability(pt):
	get_node("ability_bar").set_val(pt)
	if pt >= 100:
		get_node("fire").set_hidden(false)
		on_fire = true
	elif on_fire:
		get_node("fire").set_hidden(true)
		on_fire = false

func get_ability():
	return get_node("ability_bar").get_val()

func is_lit():
	return on_fire

func copy(portrait):
	#on_fire = portrait.is_lit()
	#set_ability(portrait.get_ability())
	#set_health(portrait.get_health())
	get_node("idol").set_texture(portrait.get_node("idol").get_texture())

func _ready():
	on_fire = false
