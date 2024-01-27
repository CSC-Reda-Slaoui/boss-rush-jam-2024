extends CharacterBody2D

@export var player : Node2D
@export var exit : Node2D
@export var spike : PackedScene
@export var snow : PackedScene

@onready var player_texture = load("res://art/player/player.png")
@onready var frostbite_texture = load("res://art/bosses/frostbite/frostbite.png")

var dialogue = [
	"Ah, a wanderer dares brave the icy expanse... What brings you to my domain?",
	"I seek only passage. I'm headed to Wraithpeak Mountain.",
	"Ah... a noble quest... but perilous. The Tundra can be unforgiving.",
	"I must get there. I don't remember why, but I must get there.",
	"You're... different than the others. You seem to have a resolve of steel... A warmth...",
	"I have made many sacrifices on my journey here.",
	"Do you really believe that your... warmth, can withstand the Frost's grasp?",
	"Enough games, let me through.",
	"Oh, what a shame... Alright then..."
]

var finish = [
	"Ah, a resilient one, you are! The dance with frost has left its mark.",
	"What have you done? I can't feel... my face.",
	"A suitable price for passage, don't you think? Your visage now adorns my icy collection.",
	"This wasn't part of the deal!",
	"Deals, mortal, are as formless and fluid as water... Amusing, isn't it? The Tundra's mark is now etched upon you... for all to see.",
]

var finished_dialogue = false
var is_fighting = false
var current_dialogue = 0
var entered = false
var should_start_dialogue = false

var health = 200

var should_start_death = false
var current_death = 0
var finished_death = false

var died = false

func take_damage():
	print("uwu")
	get_node("Sprite2D").modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	get_node("Sprite2D").modulate = Color.WHITE
	health -= 10
	
	if health <= 0:
		died = true

func _ready():
	player.get_node("Camera2D/HUD/HBoxContainer").state = 1
	player.acceleration /= 10
	player.friction /= 10
	player.health *= 2
	player.max_jump = 2

var fly_height = 30
var curr_position = 1

func move():
	if not is_fighting:
		return
	
	var target_position = Vector2(0, 0)
	if curr_position == 0:
		target_position.x = 450
		curr_position = 1
	else:
		target_position.x = 100
		curr_position = 0
	#while abs(position.x - target_position.x) > 0.1:
	#position.x = lerp(position.x, target_position.x, 0.1)
	var xtween = get_tree().create_tween()
	var ytween = get_tree().create_tween()
	xtween.tween_property(self, "position:x", target_position.x, 2).set_trans(Tween.TRANS_CUBIC)
	ytween.tween_property(self, "position:y", 154, 1).set_trans(Tween.TRANS_BACK)
	ytween.tween_property(self, "position:y", 119, 1).set_trans(Tween.TRANS_BACK)
	#position.x = target_position.x

func _physics_process(delta):
	if abs(player.position.x - position.x) < 50 and not finished_dialogue:
		should_start_dialogue = true
		player.can_move = false
		player.position.y = 184
		player.set_physics_process(false)
	
	if not finished_death and died:
		Global.stop()
		player.can_move = false
		player.set_physics_process(false)
		player.position.y = 184
		is_fighting = false
		get_node("CanvasLayer").visible = true
		player.get_node("AnimatedSprite2D").play("idle")
		if current_death % 2 == 0:
			get_node("CanvasLayer/TextureRect").texture = frostbite_texture
			get_node("CanvasLayer/Label").text = "Frostbite: " + finish[current_death]
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
		if current_dialogue == 0 and not entered:
			#$AnimatedSprite2D.play("enter")
			#$CPUParticles2D.emitting = true
			entered = true
			#$AnimatedSprite2D.flip_h = true
		if current_dialogue % 2 == 0:
			get_node("CanvasLayer/TextureRect").texture = frostbite_texture 
			get_node("CanvasLayer/Label").text = "Frostbite: " + dialogue[current_dialogue]
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
	
	if finished_death:
		exit.position.y = 0
		is_fighting = false
		player.can_move = true
		player.set_physics_process(true)
		#position.y = 137
		set_physics_process(false)
		#$AnimatedSprite2D.play("death")
		#$CPUParticles2D.emitting = false
		await get_tree().create_timer(2).timeout
	
	if is_fighting:
		var n = randi_range(1, 100)
		
		if n == 20:
			var s = spike.instantiate()
			owner.add_child(s)
			s.position.y = 161
			s.position.x = player.position.x + randi_range(-20, 20)
			s.position.x = clampi(s.position.x, -12, 575)

func rain_attack():
	$CPUParticles2D.emitting = true
	await get_tree().create_timer(2).timeout
	$CPUParticles2D.emitting = false
	
	var num_balls = randi_range(25, 45)
	for i in range(num_balls):
		var b = snow.instantiate()
		b.position.y = randi_range(-200, 0)
		b.position.x = randi_range(-35, 581)
		owner.add_child(b)

func _on_timer_timeout():
	if is_fighting:
		rain_attack()

func _on_move_timer_timeout():
	move()
