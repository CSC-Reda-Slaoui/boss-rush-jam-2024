extends CharacterBody2D

@export var player : Node2D
@export var spike : PackedScene

func take_damage():
	get_node("Sprite2D").modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	get_node("Sprite2D").modulate = Color.WHITE

func _ready():
	player.acceleration /= 10
	player.friction /= 10
	player.health *= 2
	player.max_jump = 2

func _physics_process(delta):
	var n = randi_range(1, 100)
	if n == 20:
		var s = spike.instantiate()
		owner.add_child(s)
		s.position.y = 161
		s.position.x = player.position.x + randi_range(-20, 20)
		s.position.x = clampi(s.position.x, -12, 575)
