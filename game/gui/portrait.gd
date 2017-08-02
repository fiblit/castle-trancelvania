extends TextureFrame

func set_health(hp):
	get_node("health_slots").set_val(hp * 20)

export var on_fire = false
func set_ability(pt):
	get_node("ability_bar").set_val(pt)
	if pt >= 100:
		get_node("fire").set_hidden(false)
		on_fire = true
	elif on_fire:
		get_node("fire").set_hidden(false)
		on_fire = false

func _ready():
	on_fire = false
