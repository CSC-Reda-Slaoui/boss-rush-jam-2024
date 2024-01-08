extends Area2D

@export var speed = 300

func _ready():
	set_physics_process(false)
	$Timer.start()
	$StartTimer.start()

func _physics_process(delta):
	position.y += speed * delta

func _on_timer_timeout():
	queue_free()

func _on_start_timer_timeout():
	set_physics_process(true)


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage()
