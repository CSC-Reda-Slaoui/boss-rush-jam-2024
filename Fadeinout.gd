extends Label

func _ready():
	var tween = get_tree().create_tween()

	tween.tween_property(self, "modulate", Color.WHITE, 2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate", Color.BLACK, 2).set_trans(Tween.TRANS_SINE)
