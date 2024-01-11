extends CharacterBody2D

@onready var state_machine = get_node("AnimationTree")["parameters/playback"]
var shadowstalker_texture = preload("res://art/bosses/shadowstalker/face.png")
var player_texture = preload("res://art/player/player.png")
@export var player : Node2D
@export var door : Node2D
@export var tendril : PackedScene
@export var bullet : PackedScene

var dialogue = [
	"Who dares intrude upon my domain, stumbling blindly into the abyss?",
	"I seek passage to the temple atop Wraithpeak Mountain. I must break this curse that binds me here.",
	"Foolish wanderer, seeking escape from the chains of fate. Do you not realize that salvation comes at a price?",
	"I'll pay any price to break this curse and return to the world above.",
	"Very well. But know this: to pass beyond, you must relinquish what you hold most dear. Your memories shall feed the void, a necessary sacrifice for your passage.",
	"I accept your challenge. I'll face your trial and claim what's mine.",
	"Then let the darkness consume your past. Enter, and face the annihilation of your memories."
]

var finished_dialogue = false
var is_fighting = false
var current_dialogue = 0
var entered = false
var should_start_dialogue = false

var health = 200
var died = false

var arena_width = 600

var b = 0

var tendrils_parent = Node2D.new()

func _ready():
	randomize()
	add_child(tendrils_parent)

func take_damage():
	get_node("Sprite2D").modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	get_node("Sprite2D").modulate = Color.WHITE
	health -= 10

var offset = 250 + randi_range(-20, 20)
func tendril_attack():
	var num_tendrils = randi_range(17, 20)
	var distance_between_tendrils = arena_width / (num_tendrils + 1)
	for i in range(num_tendrils):
		var t = tendril.instantiate()
		
		t.position.x = distance_between_tendrils * (i + 1) - offset
		t.position.y = -70
		add_child(t)

var num_bullets = 1

func horizontal_attack():
	var positions = [25, 457]
	state_machine.travel("death")
	await get_tree().create_timer(3).timeout
	if position.x == 303:
		var ind = randi_range(0, 1)
		position.x = positions[ind]
	elif position.x == 25:
		position.x = 457
		$Sprite2D.flip_h = true
	else:
		position.x = 25
		$Sprite2D.flip_h = false
	state_machine.travel("enter")
	await get_tree().create_timer(4).timeout
	state_machine.travel("side")
	await get_tree().create_timer(1.4).timeout
	
	for i in range(num_bullets):
		var b = bullet.instantiate()
		if position.x == 457:
			b.speed *= -1
			b.get_node("Sprite2D").flip_h = true
		add_child(b)
		b.transform = $Muzzle.transform
		b.position.y += randi_range(-2, 7)

func return_to_center():
	if position.x == 303:
		return
	
	state_machine.travel("death")
	await get_tree().create_timer(3).timeout
	position.x = 303
	state_machine.travel("enter")
	await get_tree().create_timer(4).timeout

func _physics_process(delta):
	if abs(player.position.x - position.x) < 50 and not finished_dialogue:
		should_start_dialogue = true
		player.can_move = false
		player.position.y = 184
		player.set_physics_process(false)
		door.position.y = 176
		# player.can_attack = false
	
	if not finished_dialogue and should_start_dialogue:
		get_node("CanvasLayer").visible = true
		player.get_node("AnimatedSprite2D").play("idle")
		if current_dialogue % 2 == 0:
			get_node("CanvasLayer/TextureRect").texture = shadowstalker_texture 
			get_node("CanvasLayer/Label").text = "Shadowstalker: " + dialogue[current_dialogue]
		else:
			get_node("CanvasLayer/TextureRect").texture = player_texture
			get_node("CanvasLayer/Label").text = "You: " + dialogue[current_dialogue]
		if Input.is_action_just_pressed("dialogue"):
			current_dialogue += 1
		if current_dialogue == 2 and not entered:
			state_machine.travel("enter")
			entered = true
			$CPUParticles2D2.visible = true
		if current_dialogue == len(dialogue):
			finished_dialogue = true
	
	if finished_dialogue:
		get_node("CanvasLayer").visible = false
		player.can_move = true
		#player.can_attack = true
		player.set_physics_process(true)
		is_fighting = true
	
	if health <= 0 and not died:
		died = true
		death()

func death():
	state_machine.travel("death")

func _on_attack_timer_timeout():
	if is_fighting and not died:
		var attack = randi_range(1, 10)
		
		if attack <= 5:
			horizontal_attack()
		if attack < 9:
			tendril_attack()
		if attack == 10:
			return_to_center()
