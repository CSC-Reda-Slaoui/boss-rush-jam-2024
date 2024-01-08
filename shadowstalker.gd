extends CharacterBody2D

@onready var state_machine = get_node("AnimationTree")["parameters/playback"]
var shadowstalker_texture = preload("res://art/bosses/shadowstalker/face.png")

@export var player : Node2D

@export var tendril : PackedScene

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

var num_tendrils = 15
var arena_width = 496

var tendrils_parent = Node2D.new()

func _ready():
	add_child(tendrils_parent)

func take_damage():
	get_node("Sprite2D").modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	get_node("Sprite2D").modulate = Color.WHITE
	health -= 10

var b = 0
var offset = 165
func tendril_attack():
	var distance_between_tendrils = arena_width / (num_tendrils + 1)
	for i in range(num_tendrils):
		var t = tendril.instantiate() 
		tendrils_parent.add_child(t)
		
		t.position.x = distance_between_tendrils * (i + 1) - offset
		t.position.y = -150


func _physics_process(delta):
	if abs(player.position.x - position.x) < 50:
		should_start_dialogue = true
		player.can_move = false
	
	if not finished_dialogue and should_start_dialogue:
		get_node("CanvasLayer").visible = true
		if current_dialogue % 2 == 0:
			get_node("CanvasLayer/TextureRect").texture = shadowstalker_texture 
			get_node("CanvasLayer/Label").text = "Shadowstalker: " + dialogue[current_dialogue]
		else:
			get_node("CanvasLayer/Label").text = "You: " + dialogue[current_dialogue]
		if Input.is_action_just_pressed("dialogue"):
			current_dialogue += 1
		if current_dialogue == 2 and not entered:
			state_machine.travel("enter")
			entered = true
		if current_dialogue == len(dialogue)  :
			finished_dialogue = true
	
	if finished_dialogue:
		get_node("CanvasLayer").visible = false
		player.can_move = true
		is_fighting = true
	
	if health <= 0 and not died:
		died = true
		state_machine.travel("death")
	
	if is_fighting and b < 1:
		tendril_attack()
		b += 1
