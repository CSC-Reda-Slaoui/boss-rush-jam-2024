extends Area2D

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage()
