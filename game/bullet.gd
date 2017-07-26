extends RigidBody2D

var velocity

func _ready():
	self.connect("body_enter", self, "_on_collision")
	self.connect("area_enter", self, "_on_collision")
	set_linear_velocity(velocity)

func init(vel):
	velocity = vel

func _on_collision(collider):
	# Destroy self, no effect
	self.queue_free()
