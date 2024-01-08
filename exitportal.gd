extends Area2D

@export var next_scene : PackedScene
@export var player : Node2D

func _on_body_entered(body):
	player.visible = false
	player.can_move = false
	$AnimatedSprite2D.play("close")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(next_scene)
