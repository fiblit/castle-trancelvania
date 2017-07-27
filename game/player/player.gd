extends KinematicBody2D

export var max_speed = 100
var velocity = Vector2(0,0)

func move(vec):
	velocity = (velocity + vec)
	var speed = velocity.length_squared()
	if speed > max_speed * max_speed:
		velocity = velocity.normalized() * max_speed

func _fixed_process(delta):
	set_pos(velocity * delta + get_pos())

func _ready():
	set_process(true)
	set_fixed_process(true)
	
func _process(delta):
	if is_colliding():
		print(get_collider(), get_collision_pos())