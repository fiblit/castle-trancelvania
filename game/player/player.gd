extends KinematicBody2D
# Did I mention that this script is a disorganized mess?
##### DID I MENTION THAT?? ????? ?? ? 

var bullet_scene = preload("res://game/bullet.tscn")
onready var root = get_tree().get_root().get_node("level")

export var max_speed = 200
export var time_to_deccel = 0.6
export var time_to_accel = 0.15
export var max_health = 5
export var health = 5
export var regen = 5 # +1 health / regen (since last hit/heal)
onready var time_to_regen = regen
export var damage_delay = 0.5
onready var to_vulnerable = 0
export var fire_rate = 0.1
onready var time_to_fire = fire_rate
export var base_aim_sight = 300
export var bullet_speed = 600
export var bullet_range = 600

export var blink_max = 0.95
export var blink_count = 2
var blink_opacity = 1
export var blink_min = 0.5

var deccel = Vector2(0, 0)
var accel = Vector2(0, 0)
var velocity = Vector2(0, 0)
var pos = Vector2(0, 0)

signal player_death

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

func set_pos(pos):
	.set_pos(pos)
	#Help detect collisions smoothly (this probably isn't performant though)
	move(Vector2(0, 0))

func get_size():
	return self.get_node("sprite").get_texture().get_size()

func aim(dir):
	var len = dir.length_squared()
	var cam = get_node("tripod")
	if len < base_aim_sight * base_aim_sight:
		cam.set_pos(dir)
	else:
		cam.set_pos(dir.normalized() * base_aim_sight)

func try_fire(ndir_to_mouse, delta):
	time_to_fire -= delta
	if time_to_fire <= 0:
		time_to_fire = fire_rate
		var radius = get_size().x * sqrt(2) / 2
		var offset_pos = get_pos() + ndir_to_mouse * radius
		var root = get_tree().get_root().get_node("level")
		root.spawn_bullet(ndir_to_mouse, offset_pos, bullet_range, bullet_speed)

func _process(delta):
	var sprite = get_node("sprite")
	
	if to_vulnerable <= 0:
		sprite.set_opacity(1)
		time_to_regen -= delta
		if time_to_regen <= 0 and health < max_health:
			health += 1
			time_to_regen = regen
	
	if to_vulnerable > 0:
		var mean = 0.5 * (blink_max + blink_min)
		var variance = 0.5 * (blink_max - blink_min)
		var anim = cos(to_vulnerable * 2 * PI * blink_count / damage_delay)
		sprite.set_opacity(mean + variance * anim)
		to_vulnerable -= delta

func _ready():
	pos = get_pos()
	set_fixed_process(true)
	set_process(true)

func bullet_hit(bullet):
	if to_vulnerable <= 0:
		to_vulnerable = damage_delay
		health -= 1
		time_to_regen = regen
		if health <= 0:
			emit_signal("player_death")