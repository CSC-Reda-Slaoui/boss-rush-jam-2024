extends Area2D

var speed = 150

func _process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage()

func _on_timer_timeout():
	queue_free()
