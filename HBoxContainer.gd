extends HBoxContainer

@onready var full1 = load("res://art/hud/heart_full1.png")
@onready var full2 = load("res://art/hud/heart_full2.png")
@onready var broken1 = load("res://art/hud/heart_broken1.png")
@onready var broken2 = load("res://art/hud/heart_broken2.png")
@onready var current_texture1 = full1
@onready var current_texture2 = full2

@export var state = 0

func update_health(health):
	for i in get_child_count():
		if state == 0:
			current_texture1 = full1
			current_texture2 = full2
		else:
			current_texture1 = broken1
			current_texture2 = broken2
		
		get_child(i).texture.set_frame_texture(0, current_texture1)
		get_child(i).texture.set_frame_texture(1, current_texture2)
		if i >= health:
			get_child(i).visible = false
