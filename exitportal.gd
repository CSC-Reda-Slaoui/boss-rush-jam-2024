extends Area2D

@export var next_scene : PackedScene
@export var player : Node2D

func _on_body_entered(body):
	player.visible = false
	player.can_move = false
	$AnimatedSprite2D.play("close")
	var tween = get_tree().create_tween()
	tween.tween_property(get_node("ColorRect"), "color:a", 1, 2)
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_packed(next_scene)
