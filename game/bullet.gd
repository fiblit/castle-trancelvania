extends RigidBody2D

var velocity = Vector2(0, 0)
var position = Vector2(0, 0)
export var base_speed = 600
export var base_range = 600

var time_to_live = 0

func _ready():
	self.connect("body_enter", self, "on_collision")
	set_process(true)
	if velocity.length_squared() > 0:
		look_at(-velocity + position)
	
	time_to_live = base_range / base_speed

func get_size():
	return get_node("rigid").get_texture().get_size()

func _process(delta):
	time_to_live -= delta
	if time_to_live <= 0:
		queue_free()

func init(vel, pos, dist, speed):
	base_range = dist
	base_speed = speed
	
	var nvel = vel.normalized()
	vel = vel.normalized() * base_speed
	velocity = vel
	position = pos + nvel * (get_size().x + get_size().y)
	set_linear_velocity(velocity)
	set_pos(position)

func on_collision(collider):
	if collider.has_method("bullet_hit"):
		collider.bullet_hit(self)
		queue_free()
