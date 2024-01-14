extends CharacterBody2D

# Abilities
@export var has_dash : bool = false
@export var max_jump : int = 1
@export var health : int =  5 

@export var speed : float = 130.0
@export var acceleration : float = 0.25
@export var friction : float = 0.5
@export var jump_velocity : float = -160.0
@export var dash_speed : float = 2400.0

@export var gravity : float = 400.0 

var dash_timer : float = 0.0
var jump_count : int = 0

var can_move : bool = true
var can_attack : bool = true
var dead : bool = false

func take_damage():
	get_node("Camera2D").add_trauma(0.3)
	get_node("AnimatedSprite2D").modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	get_node("AnimatedSprite2D").modulate = Color.WHITE
	
	health -= 1
	
	if health == 0:
		position.y = 183.924011230469
		$AnimatedSprite2D.play("death")
		dead = true
		
		Global.stop()
		await get_tree().create_timer(2).timeout
		get_tree().reload_current_scene()

func _physics_process(delta):
	if not can_attack or dead:
		can_move = false
	elif can_attack:
		can_move = true

	get_node("Camera2D/HUD/HBoxContainer").update_health(health)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump.
	if is_on_floor():
		jump_count = 0
	
	if Input.is_action_pressed("down"):
		$AnimatedSprite2D.play("crouch")
		$CollisionShape2D.scale = Vector2(0.5, 0.5)
		$CollisionShape2D.position.y = 0
		velocity.x = lerp(velocity.x, 0.0, 0.05)
		move_and_slide()
		return
	else:
		$CollisionShape2D.position.y = -2
		$CollisionShape2D.scale = Vector2(1, 1)
	
	if Input.is_action_just_pressed("jump") and jump_count < max_jump and can_move:
		velocity.y = jump_velocity
		jump_count += 1
	
	var direction = Input.get_axis("left", "right") if can_move else 0
	if direction:
		$AnimatedSprite2D.play("run")
		velocity.x = lerp(velocity.x, float(direction * speed), acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
		#if abs(velocity.x) > 0.00001:
			#$AnimatedSprite2D.play("stop")
		if can_attack and not dead:
			$AnimatedSprite2D.play("idle")
	
	if velocity.y < 0:
		$AnimatedSprite2D.play("jump")
	elif velocity.y != 0 and abs(velocity.y) < 0.1:
		$AnimatedSprite2D.play("hang")
	elif velocity.y > 0:
		$AnimatedSprite2D.play("fall")
	
	if direction > 0:
		get_node("AnimatedSprite2D").flip_h = false
		get_node("Sword").rotation = 0
	elif direction < 0:
		get_node("AnimatedSprite2D").flip_h = true
		get_node("Sword").rotation = PI

	if Input.is_action_just_pressed("attack") and can_attack:
		can_attack = false
		$AnimatedSprite2D.play("attack")
		get_node("Sword").monitoring = true
		if not is_on_floor():
			velocity.y = 0
			gravity = 0
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
	gravity = 400

func _on_cooldown_timer_timeout():
	can_attack = true
