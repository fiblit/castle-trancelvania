extends RigidBody2D

export var health = 1
export var max_speed = 200
var random_timer = 0

func _fixed_process(delta):
	random_timer -= delta
	if random_timer <= 0:
		random_timer = randf() * 0.5 + 0.1
		var dir = Vector2(randf() - 0.5, randf() - 0.5).normalized()
		set_linear_velocity(max_speed * dir)
	set_z(get_pos().y)

func bullet_hit(bullet):
	bullet.die_on_hit = false
	
func _ready():
	set_fixed_process(true)
