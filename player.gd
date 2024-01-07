extends CharacterBody2D

# Abilities
@export var has_dash : bool = false
@export var max_jump : int = 1

@export var speed : float = 300.0
@export var acceleration : float = 0.25
@export var friction : float = 0.25
@export var jump_velocity : float = -300.0
@export var jump_height : float = 0.3
@export var dash_speed : float = 2400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jump_timer : float = 0.0
var dash_timer : float = 0.0
var jump_count : int = 0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump.
	if is_on_floor():
		jump_count = 0
	
	if Input.is_action_just_pressed("jump") and jump_count < max_jump:
		velocity.y = jump_velocity
		jump_count += 1
	
	if Input.is_action_pressed("jump") and jump_timer < 0.3:
		velocity.y = (jump_velocity - abs(velocity.x / 3))
		jump_timer += delta
	
	if not Input.is_action_pressed("jump") and jump_count < max_jump:
		jump_timer = 0.0
	
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = lerp(velocity.x, float(direction * speed), acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
	
	if Input.is_action_just_pressed("dash") and dash_timer == 0.0 and has_dash:
		velocity.x = dash_speed * direction
		dash_timer = 1
	else:
		dash_timer -= delta
		dash_timer = clamp(dash_timer, 0.0, 1.0)
	
	move_and_slide()
