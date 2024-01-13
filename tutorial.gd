extends Node2D

func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(get_node("ColorRect2"), "color:a", 0, 2)

func _process(delta):
	get_node("PlayerIndicator").position.x = lerp(get_node("PlayerIndicator").position.x, get_node("Player").position.x, 0.25)
