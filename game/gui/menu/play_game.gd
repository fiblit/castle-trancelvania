extends Button

func _on_pressed():
	get_node("/root/scene_changer").goto_scene("res://game/scenes/main.tscn")

func _ready():
	self.connect("pressed", self, "_on_pressed")
