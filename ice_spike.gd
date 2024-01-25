extends Area2D

func _ready():
	monitoring = false
	await get_tree().create_timer(1).timeout
	$AnimatedSprite2D.visible = true
	$CPUParticles2D.emitting = false
	$AnimatedSprite2D.play("default")
	await get_tree().create_timer(0.2).timeout
	monitoring = true
	await get_tree().create_timer(1).timeout
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage()
