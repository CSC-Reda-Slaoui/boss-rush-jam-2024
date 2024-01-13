extends Node2D

func _ready():
	Global.main()

func _on_label_2_pressed():
	var tween = get_tree().create_tween()
	
	get_node("ColorRect2").visible = true
	
	await tween.tween_property(get_node("ColorRect2"), "color:a", 1, 2).finished
	get_tree().change_scene_to_file("res://tutorial.tscn")
