extends RigidBody2D

var velocity
var position
export var base_speed = 1600

func _ready():
	self.connect("body_enter", self, "_on_collision")
	set_linear_velocity(velocity)
	set_pos(position)

func init(vel, pos):
	vel = vel.normalized() * base_speed
	velocity = vel
	position = pos

func _on_collision(collider):
	# Destroy self, no effect
	self.queue_free()
