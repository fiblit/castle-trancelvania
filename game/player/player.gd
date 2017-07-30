extends KinematicBody2D

export var max_speed = 200
export var time_to_deccel = 0.6
export var time_to_accel = 0.15
var deccel = Vector2(0, 0)
var accel = Vector2(0, 0)
var velocity = Vector2(0, 0)
var pos = Vector2(0, 0)

func deccel():
	deccel = (1 / time_to_deccel) * velocity
	accel = Vector2(0, 0)

func accel(vec):
	deccel = Vector2(0, 0) #prevents the jerking turn-around (maybe wanted)
	accel = vec.normalized() * max_speed / time_to_accel

func _fixed_process(delta):
	pos = get_pos()#account for collisions/teleports
	
	#This is poor integration, however it doesn't need to be good. The character
	#already has unrealistic physics. If it drifts from reality over time, that
	#is fine. Acceleration is instantaneous, but decceleration is not.
	
	velocity += accel * delta
	
	#if deccelerating
	if deccel.length_squared() > 0:
		velocity -= deccel * delta
		
		#If velocity has been deccelerated to the point that it moves back a bit
		if velocity.dot(-deccel) > 0:
			#stop moving!
			velocity = Vector2(0, 0)
			deccel = Vector2(0, 0)
	
	var speed = velocity.length_squared()
	if speed > max_speed * max_speed:
		velocity = velocity.normalized() * max_speed
	
	pos += velocity * delta
	set_pos(pos)

func get_size():
	return self.get_node("sprite").get_texture().get_size()

func _ready():
	pos = get_pos()
	set_process(true)
	set_fixed_process(true)
	
func _process(delta):
	if is_colliding():
		print(get_collider(), get_collision_pos())