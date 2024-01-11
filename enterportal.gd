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
	var tween = get_tree().create_tween()
	tween.tween_property(get_node("ColorRect"), "color:a", 0, 2)
	await get_tree().create_timer(2).timeout
	visible = false
	player.can_move = true
