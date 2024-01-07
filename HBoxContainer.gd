extends HBoxContainer

func update_health(health):
	for i in get_child_count():
		if i >= health:
			get_child(i).visible = false
