extends Sprite

var bounds = null

func _ready():
	bounds = get_node("Rigid")
	bounds.connect("body_enter", self, "_on_collision")
	bounds.connect("area_enter", self, "_on_collision")

func _init(vel):
	pass

func _on_collision(collider):
	# Destroy self, no effect
	self.queue_free()
