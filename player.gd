extends CharacterBody2D

# Abilities
@export var has_dash : bool = false
@export var max_jump : int = 1
@export var health : int =  4

@export var speed : float = 130.0
@export var acceleration : float = 0.25
@export var friction : float = 0.25
@export var jump_velocity : float = -160.0
@export var dash_speed : float = 2400.0

@export var gravity : float = 400.0 

var dash_timer : float = 0.0
var jump_count : int = 0

var can_move : bool = true
var can_attack : bool = true

func take_damage():
	health -= 1
	if health == 0:
		print("ded")
		get_tree().reload_current_scene()

func _physics_process(delta):
	get_node("Camera2D/HUD/HBoxContainer").update_health(health)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump.
	if is_on_floor():
		jump_count = 0
	
	if Input.is_action_just_pressed("jump") and jump_count < max_jump and can_move:
		velocity.y = jump_velocity
		jump_count += 1
	
	var direction = Input.get_axis("left", "right") if can_move else 0
	if direction:
		velocity.x = lerp(velocity.x, float(direction * speed), acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
	
	if direction > 0:
		get_node("Sprite2D").flip_h = false
		get_node("Sword").rotation = 0
	elif direction < 0:
		get_node("Sprite2D").flip_h = true
		get_node("Sword").rotation = PI
	
	if Input.is_action_pressed("down"):
		get_node("Sword").rotation = PI / 2
	
	if Input.is_action_pressed("up"):
		get_node("Sword").rotation = 3 * PI / 2

	if Input.is_action_just_pressed("attack") and can_attack:
		can_attack = false
		get_node("Sword").monitoring = true
		get_node("Sword/VisibilityTimer").start()
		get_node("Sword/CooldownTimer").start()
	
	if Input.is_action_just_pressed("dash") and dash_timer == 0.0 and has_dash and can_move:
		velocity.x = dash_speed * direction
		dash_timer = 1
	else:
		dash_timer -= delta
		dash_timer = clamp(dash_timer, 0.0, 1.0)
	
	move_and_slide()

func _on_timer_timeout():
	get_node("Sword").monitoring = false

func _on_cooldown_timer_timeout():
	can_attack = true
