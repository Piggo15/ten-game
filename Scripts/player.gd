extends CharacterBody3D

@export var walk_speed = 5.0
@export var sprint_speed = 7.5
@export var jump_velocity = 4.5
@export var start_y_rotation = 0
@export var sensitivity = 0.005
@export var rest_fov = 75.0
@export var fov_change_speed = 1.5
@export var view_bob = true
@export var bob_frequency = 2.0
@export var bob_amplitude = 0.08
@export var level = 1
@export var in_final_level = false

var speed = walk_speed
var bob_t = 0.0
var land_sound_ready = false
var footstep_sound_ready = true
var died = false
var won = false

@onready var camera = $CameraPosition/Camera3D
@onready var camera_position = $CameraPosition
@onready var footstep_sfx = $FootstepSound
@onready var jump_sfx = $JumpSound
@onready var death_sfx = $DeathSound
@onready var win_sfx = $WinSound
@onready var timer = %Timer
@onready var level_manager = get_tree().current_scene
@onready var settings_manager = get_tree().current_scene.get_child(1)
@onready var enemy_manager = %EnemyManager
@onready var ui = $Control
@onready var win_screen_scene = preload("res://Prefab Scenes/win_screen.tscn")
@onready var final_win_screen_scene = preload("res://Prefab Scenes/final_win_screen.tscn")
@onready var death_screen_scene = preload("res://Prefab Scenes/death_screen.tscn")
@onready var level_label: Label = $Control/LevelLabel

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	level_label.text = "Level " + str(level)
	camera_position.rotation.y = start_y_rotation
	
	sensitivity = settings_manager.sensitivity

func _unhandled_input(event: InputEvent) -> void:
	if died or won:
		return
		
	if event is InputEventMouseMotion:
		camera_position.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	
	if died or won:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if is_on_floor() and land_sound_ready:
		land_sound_ready = false
		# just re using footstep sound for landing for now
		footstep_sfx.pitch_scale = randf_range(0.9, 1.2)
		footstep_sfx.play()
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		jump_sfx.pitch_scale = randf_range(0.9, 1.2)
		jump_sfx.play()
		land_sound_ready = true
	
	# Handle sprint
	
	if Input.is_action_just_pressed("sprint"):
		speed = sprint_speed
	if Input.is_action_just_released("sprint"):
		speed = walk_speed

	
	# Get the input direction and handle the movement/deceleration.
	
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (camera_position.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7)
	
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3)
	
	# fov
	var velocity_clamped = clamp(velocity.length(), 0.5, sprint_speed * 2)
	var target_fov = rest_fov + fov_change_speed * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	# head bob
	bob_t += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(bob_t)
	
	move_and_slide()

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_frequency) * bob_amplitude
	pos.x = cos(time * bob_frequency / 2) * bob_amplitude
	play_footstep_sound(pos.y)
	return pos

func play_footstep_sound(pos_y):
	
	if pos_y <= -bob_amplitude * 0.9 and footstep_sound_ready:
		footstep_sfx.pitch_scale = randf_range(0.9, 1.2)
		footstep_sfx.play()
		footstep_sound_ready = false
	elif pos_y > 0:
		footstep_sound_ready = true

func _on_hurtbox_body_entered(_body: Node3D) -> void:
	if !died and !won:
		die("Died to Bullet!")

func die(message):
	died = true
	clear_game()
	var death_screen = death_screen_scene.instantiate()
	get_parent().add_child(death_screen)
	death_sfx.play()
	death_screen.update_death_message(message)

func win():
	won = true
	clear_game()
	
	if in_final_level:
		var final_win_screen = final_win_screen_scene.instantiate()
		add_child(final_win_screen)
	
	else:
		var win_screen = win_screen_scene.instantiate()
		add_child(win_screen)
	
	win_sfx.play()

func clear_game():
	enemy_manager.clear_enemies()
	enemy_manager.enemy_count_label.queue_free()
	timer.display_label.queue_free()
	ui.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
