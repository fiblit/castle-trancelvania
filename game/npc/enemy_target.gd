extends Area2D

func bullet_hit(bullet):
	var p = get_parent()
	var from = bullet.from
	
	if from != "enemy":
		print(from)
		p.health -= 1
		if p.health <= 0:
			p.queue_free()
	#else:
	#	bullet.die_on_hit = false
