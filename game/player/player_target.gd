extends KinematicBody2D

onready var p = get_parent()
func bullet_hit(bullet):
	if p.to_vulnerable <= 0:
		p.to_vulnerable = p.damage_delay
		p.set_health(p.health - 1)
		p.time_to_regen = p.regen
		if p.health <= 0:
			p.emit_signal("player_death")
