extends CharacterBody2D

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

func _ready():
	get_node("CanvasLayer/Panel").position.x = 50
	get_node("CanvasLayer/Panel").size.x = get_viewport_rect().size.x - 50
	
	get_node("CanvasLayer/Label").position.x = 50
	get_node("CanvasLayer/Label").size.x = get_viewport_rect().size.x - 50
	
	get_node("CanvasLayer/Panel").position.y = get_viewport_rect().size.y - 200
	get_node("CanvasLayer/Panel").size.y = 50
	
	get_node("CanvasLayer/Label").position.y = get_viewport_rect().size.y - 200
	get_node("CanvasLayer/Label").size.y = 50

func _physics_process(delta):
	if not finished_dialogue:
		get_node("CanvasLayer").visible = true
		if current_dialogue % 2 == 0:
			get_node("CanvasLayer/Label").text = "Shadowstalker: " + dialogue[current_dialogue]
		else:
			get_node("CanvasLayer/Label").text = "You: " + dialogue[current_dialogue]
		if Input.is_action_just_pressed("dialogue"):
			current_dialogue += 1

		if current_dialogue == len(dialogue) - 1:
			finished_dialogue = true
		
