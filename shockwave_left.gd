extends Area2D

func _process(delta):
	position.x -= 3

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage()
