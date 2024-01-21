extends CharacterBody2D

@onready var state_machine = get_node("AnimationTree")["parameters/playback"]
var shadowstalker_texture = preload("res://art/bosses/shadowstalker/face.png")
var player_texture = preload("res://art/player/player.png")
@export var player : Node2D
@export var door : Node2D
@export var exit : Node2D
@export var tendril : PackedScene
@export var bullet : PackedScene

var dialogue = [
	"Who dares intrude upon my domain, stumbling blindly into the darkness?",
	"I seek passage to the temple atop Wraithpeak Mountain. I must break this curse that binds me here.",
	"Foolish wanderer, seeking escape from the chains of fate. Do you not realize that salvation comes at a price?",
	"I'll pay any price to break this curse and return to the world above.",
	"Very well. Your memories shall feed the void, a necessary sacrifice for your passage. Challenge me, and face the annihilation of your memories."
]

var finish = [
	"ENOUGH! I shall allow you passage.",
	"What has happened? Something feels amiss. You are the first and only thing I can remember.",
	"Memories are naught but fragments of a former self. They are of no use to you in the journey ahead. Embrace the emptiness; within it, you'll find a canvas anew."
]

var finished_dialogue = false
var is_fighting = false
var current_dialogue = 0
var entered = false
var should_start_dialogue = false

var should_start_death = false
var current_death = 0
var finished_death = false

var health = 200
var died = false

var arena_width = 550

var b = 0

var tendrils_parent = Node2D.new()

func _ready():
	Global.stop()
	randomize()
	add_child(tendrils_parent)
	# Global.shadowstalker()

func take_damage():
	get_node("Sprite2D").modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	get_node("Sprite2D").modulate = Color.WHITE
	health -= 10

var offset = 250 + randi_range(-20, 20)
func tendril_attack():
	var num_tendrils = randi_range(12, 15)
	var distance_between_tendrils = arena_width / (num_tendrils + 1)
	for i in range(num_tendrils):
		var t = tendril.instantiate()
		
		t.z_index = 0
		t.scale = Vector2(1.3, 1.63)
		t.global_position.x = 215 + distance_between_tendrils * (i + 1) - offset
		t.global_position.y = 30
		owner.add_child(t)

var num_bullets = 1

func horizontal_attack():
	if not is_fighting:
		return
	
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
		owner.add_child(b)
		b.global_transform = $Muzzle.global_transform
		b.position.y += randi_range(15, 15)

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
	
	if not finished_death and died:
		Global.stop()
		player.can_move = false
		player.set_physics_process(false)
		is_fighting = false
		get_node("CanvasLayer").visible = true
		player.get_node("AnimatedSprite2D").play("idle")
		if current_death % 2 == 0:
			get_node("CanvasLayer/TextureRect").texture = shadowstalker_texture
			get_node("CanvasLayer/Label").text = "Shadowstalker: " + finish[current_death]
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
			Global.shadowstalker()
			$CPUParticles2D2.visible = true
		if current_dialogue == len(dialogue):
			finished_dialogue = true
	
	if finished_dialogue:
		get_node("CanvasLayer").visible = false
		player.can_move = true
		player.set_physics_process(true)
		is_fighting = true
	
	if health <= 0 and not died:
		died = true
		should_start_death = true
	
	if finished_death:
		is_fighting = false
		exit.position.y = 0
		player.can_move = true
		player.set_physics_process(true)
		state_machine.travel("death")
		await get_tree().create_timer(4).timeout
		queue_free()

func _on_attack_timer_timeout():
	if is_fighting and not died:
		var attack = randi_range(1, 10)
		
		if attack <= 5:
			horizontal_attack()
		if attack < 9:
			tendril_attack()
		if attack == 10:
			return_to_center()
