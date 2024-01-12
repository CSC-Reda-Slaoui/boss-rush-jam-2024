extends Node2D

@export var speed = 300

var move = false

func _ready():
	$Area2D.monitoring = false
	$StartTimer.start()

func _on_start_timer_timeout():
	$Area2D.monitoring = true

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage()

func _on_animated_sprite_2d_animation_finished():
	queue_free()
