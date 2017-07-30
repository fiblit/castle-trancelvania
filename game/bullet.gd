extends RigidBody2D

var velocity = Vector2(0, 0)
var position = Vector2(0, 0)
export var base_speed = 600

func _ready():
	self.connect("body_enter", self, "on_collision")
	if velocity.length_squared() > 0:
		look_at(-velocity + position)

func get_size():
	return get_node("rigid").get_texture().get_size()

func init(vel, pos):
	var nvel = vel.normalized()
	vel = vel.normalized() * base_speed
	velocity = vel
	position = pos + nvel * get_size().x
	set_linear_velocity(velocity)
	set_pos(position)

func on_collision(collider):
	if collider.has_method("bullet_hit"):
		collider.bullet_hit()
	# Destroy self, no effect
	queue_free()
