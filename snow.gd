extends Area2D

var speed
@onready var rot_speed = randi_range(-10, 10)

func _ready():
	randomize()
	var s = randf_range(0.5, 1.0)
	scale = Vector2(s, s)
	speed = randi_range(60, 100)

func _process(delta):
	$Sprite2D.rotation += rot_speed * delta
	position.y += speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage()
	monitoring = false
	position.y += 5
	$Sprite2D.visible = false
	$CPUParticles2D.emitting = true
	await get_tree().create_timer(2).timeout
	queue_free()
