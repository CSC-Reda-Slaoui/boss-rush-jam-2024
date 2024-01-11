extends Label

var tween

@export var next_scene : PackedScene

func _ready():
	var tween = get_tree().create_tween()
	
	await tween.tween_property(self, "modulate", Color.WHITE, 3)
	await tween.tween_property(self, "visible_ratio", 1, 10)
	await tween.tween_property(self, "modulate", Color.BLACK, 2).finished
	
	get_tree().change_scene_to_packed(next_scene)
