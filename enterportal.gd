extends Area2D

@export var player : Node2D

func _ready():
	player.visible = false
	player.can_move = false
	$AnimatedSprite2D.play("open")
	await get_tree().create_timer(1).timeout
	player.visible = true
	player.position = position
	player.velocity.x = 400
	$AnimatedSprite2D.play("close")
	await get_tree().create_timer(1).timeout
	visible = false
	player.can_move = true
