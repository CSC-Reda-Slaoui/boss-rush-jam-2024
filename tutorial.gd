extends Node2D

func _process(delta):
	get_node("PlayerIndicator").position.x = lerp(get_node("PlayerIndicator").position.x, get_node("Player").position.x, 0.25)
