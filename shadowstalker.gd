extends CharacterBody2D

@onready var state_machine = get_node("AnimationTree")["parameters/playback"]

var dialogue = [
	"Who dares intrude upon my domain, stumbling blindly into the abyss?",
	"I seek passage to the temple atop Wraithpeak Mountain. I must break this curse that binds me here.",
	"Foolish wanderer, seeking escape from the chains of fate. Do you not realize that salvation comes at a price?",
	"I'll pay any price to break this curse and return to the world above.",
	"Very well. But know this: to pass beyond, you must relinquish what you hold most dear. Your memories shall feed the void, a necessary sacrifice for your passage.",
	"I accept your challenge. I'll face your trial and reclaim what's mine.",
	"Then let the darkness consume your past. Enter, and face the annihilation of your memories."
]

var finished_dialogue = false
var current_dialogue = 0
var entered = false

func _physics_process(delta):
	if not finished_dialogue:
		get_node("CanvasLayer").visible = true
		if current_dialogue % 2 == 0:
			get_node("CanvasLayer/Label").text = "Shadowstalker: " + dialogue[current_dialogue]
		else:
			get_node("CanvasLayer/Label").text = "You: " + dialogue[current_dialogue]
		if Input.is_action_just_pressed("dialogue"):
			current_dialogue += 1
		if current_dialogue == 2 and not entered:
			state_machine.travel("enter")
			entered = true
		if current_dialogue == len(dialogue) - 1:
			finished_dialogue = true
		
