extends Area2D

func bullet_hit(bullet):
	var p = get_parent()
	p.health -= 1
	if p.health <= 1:
		p.queue_free()
