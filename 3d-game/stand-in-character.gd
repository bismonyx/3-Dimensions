extends CharacterBody3D

# --- Variables ---
var speed = 7
var acceleration = 20
var gravity = 9.8
var jump = 5

var mouse_sensitivity = 0.05
var weapon_to_spawn
var weapon_to_drop
var direction = Vector3()
var fall = Vector3()

# --- Node References ---
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var reach = $Head/Camera3D/Reach
@onready var hand = $Head/Hand

# --- Preloaded Weapons ---
@onready var weapon_hr = preload("res://weapon_hr.tscn")
@onready var weapon = preload("res://weapon.tscn")

# --- Ready ---
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# --- Input: Mouse movement only ---
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

# --- Process: Handles movement + weapon interaction ---
func _process(delta):
	handle_weapon_interaction()
	handle_movement(delta)

# --- Handle Weapon Pick-up and Drop ---
func handle_weapon_interaction():
	if reach.is_colliding():
		if reach.get_collider().get_name() == "weapon":
			weapon_to_spawn = weapon_hr.instantiate()
	else:
		weapon_to_spawn = null
		
	if hand and hand.get_child_count() > 0:
		if hand.get_child(0).get_name() == "weapon_hr":
			weapon_to_drop = weapon.instantiate()
	else:
		weapon_to_drop = null
		
	if Input.is_action_just_pressed("interact"):
		if weapon_to_spawn != null:
			if hand.get_child_count() > 0:
				get_parent().add_child(weapon_to_drop)
				weapon_to_drop.global_transform = hand.global_transform
				weapon_to_drop.dropped = true
				hand.get_child(0).queue_free()
			reach.get_collider().queue_free()
			hand.add_child(weapon_to_spawn)
			weapon_to_spawn.rotation = hand.rotation

# --- Handle Movement and Jumping ---
func handle_movement(delta):
	direction = Vector3()

	if not is_on_floor():
		fall.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		fall.y = jump

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z

	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction = direction.normalized()

	velocity = velocity.lerp(direction * speed, acceleration * delta)
	velocity.y = fall.y
	move_and_slide()
	fall.y = velocity.y
