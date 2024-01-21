extends CharacterBody2D

@export var player : Node2D
@export var shockwave_left : PackedScene
@export var shockwave_right: PackedScene

@export var door : Node2D
@export var exit : Node2D

var player_texture = load("res://art/player/player.png")
var pyroclast_texture = load("res://art/bosses/pyroclast/pyroclast.png")

const speed = 400
var amplitude = 10
const limit = 550
var direction = -1
var height = 140
var smash_height = 10
var random_switch_chance = 0.02

var dialogue = [
	"Another warrior... come to challenge guardian of flame?",
	"I seek passage across your forge. My destination is the temple atop Wraithpeak Mountain.",
	"Foolish mortal! You'll never reach it. This realm devours all who enter. Your desires shall crumble to ash.",
	"I shall face the challenges. I won't be deterred.",
	"Is the fire within you determination... or mere recklessness?",
	"Call it what you will. Let me pass.",
	"To challenge me, you must offer something precious in return. Perhaps the ability to feel? Emotions are a vulnerability, a weakness. You should thank me for this favor.",
	"I accept your bargain.",
	"Then raise your sword, and let your soul be cleansed from sentimentality in the crucible of flame."
]

var finish = [
	"Enough!",
	"Allow me to pass.",
	"You are resilient. I shall permit your passage. Just know, the path ahead is even more so treacherous.",
	"I'll face whatever comes. The journey must continue.",
	"Proceed, but be wary. The forge has molded you, yet another trial awaits above."
]

var finished_dialogue = false
var is_fighting = false
var current_dialogue = 0
var entered = false
var should_start_dialogue = false

var should_start_death = false
var current_death = 0
var finished_death = false

var died = false

var health = 100

var b = 0

func take_damage():
	get_node("AnimatedSprite2D").modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	get_node("AnimatedSprite2D").modulate = Color.WHITE
	health -= 10
	
	if health <= 0:
		died = true

func _ready():
	Global.stop()
	player.max_jump = 2
	$Laser.monitoring = false

var cur_attacking = false

func _physics_process(delta):
	if abs(player.position.x - position.x) < 50 and not finished_dialogue:
		should_start_dialogue = true
		player.can_move = false
		player.position.y = 172
		player.set_physics_process(false)
		#door.position.y = 176
	
	if not finished_death and died:
		Global.stop()
		player.can_move = false
		player.set_physics_process(false)
		player.position.y = 172
		is_fighting = false
		get_node("CanvasLayer").visible = true
		player.get_node("AnimatedSprite2D").play("idle")
		if current_death % 2 == 0:
			get_node("CanvasLayer/TextureRect").texture = pyroclast_texture
			get_node("CanvasLayer/Label").text = "Pyroclast: " + finish[current_death]
		else:
			get_node("CanvasLayer/TextureRect").texture = player_texture
			get_node("CanvasLayer/Label").text = "You: " + finish[current_death]
		if Input.is_action_just_pressed("dialogue"):
			current_death += 1
		if current_death == len(finish):
			finished_death = true
			get_node("CanvasLayer").visible = false
		return
	
	if not finished_dialogue and should_start_dialogue:
		if current_dialogue == 0:
			Global.pyroclast()
		get_node("CanvasLayer").visible = true
		player.get_node("AnimatedSprite2D").play("idle")
		door.position.y = 164
		if current_dialogue == 0 and not entered:
			$AnimatedSprite2D.play("enter")
			$CPUParticles2D.emitting = true
			entered = true
			$AnimatedSprite2D.flip_h = true
		if current_dialogue % 2 == 0:
			get_node("CanvasLayer/TextureRect").texture = pyroclast_texture 
			get_node("CanvasLayer/Label").text = "Pyroclast: " + dialogue[current_dialogue]
		else:
			get_node("CanvasLayer/TextureRect").texture = player_texture
			get_node("CanvasLayer/Label").text = "You: " + dialogue[current_dialogue]
		if Input.is_action_just_pressed("dialogue"):
			current_dialogue += 1
		if current_dialogue == len(dialogue):
			finished_dialogue = true
	
	if finished_dialogue:
		get_node("CanvasLayer").visible = false
		player.can_move = true
		player.set_physics_process(true)
		is_fighting = true
	
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	
	var n = randi_range(0, 20)
	
	if n == 20 and not cur_attacking and is_fighting:
		laser_attack()
	
	if n <= 18 and is_fighting:
		move_sine(delta)
	
	if finished_death:
		exit.position.y = 0
		is_fighting = false
		player.can_move = true
		player.set_physics_process(true)
		position.y = 137
		set_physics_process(false)
		$AnimatedSprite2D.play("death")
		$CPUParticles2D.emitting = false
		await get_tree().create_timer(2).timeout

func laser_attack():
	cur_attacking = true
	$CPUParticles2D2.emitting = true
	await get_tree().create_timer(0.75).timeout
	$Laser.monitoring = true
	$Laser/ColorRect.visible = true
	$CPUParticles2D2.emitting = false
	await get_tree().create_timer(1).timeout
	$Laser.monitoring = false
	$Laser/ColorRect.visible = false
	await get_tree().create_timer(2).timeout
	cur_attacking = false
	

func smash_attack():
	if not is_fighting:
		return
	
	velocity.x = lerp(velocity.x, 0.0, 0.1)
	
	var orig_y = global_position.y
	var target_y = global_position.y - smash_height
	
	$AnimatedSprite2D.play("smash")
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:y", 80, 2.0).set_trans(Tween.TRANS_LINEAR)
	await tween.tween_property(self, "global_position:y", 162, 0.5).set_trans(Tween.TRANS_QUART).finished
	#await tween.tween_property(self, "global_position:y", orig_y, 1.0).finished
	
	player.get_node("Camera2D").add_trauma(0.4)
	
	var left = shockwave_left.instantiate()
	var right = shockwave_right.instantiate()
	
	left.scale = Vector2(2, 2)
	right.scale = Vector2(2, 2)
	
	left.global_position.y = 165
	right.global_position.y = 165
	
	left.global_position.x = global_position.x
	right.global_position.x = global_position.x
	
	left.z_index = -1
	right.z_index = -1
	
	owner.add_child(left)
	owner.add_child(right)
	
	$AnimatedSprite2D.play("idle")

func move_sine(delta):
	var offset = amplitude * sin(global_position.x / 50)

	if randf() < random_switch_chance:
		amplitude *= -1

	global_position.x = lerp(global_position.x, global_position.x + direction * speed * delta, 0.2)
	global_position.y = lerp(global_position.y, offset + height + amplitude * sin(global_position.x / 50), 0.05)

	if global_position.x < 0 or global_position.x > limit:
		if $AnimatedSprite2D.flip_h:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true
		direction *= -1

	move_and_slide()

func _on_timer_timeout():
	smash_attack()

func _on_laser_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage()
