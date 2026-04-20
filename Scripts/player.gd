extends CharacterBody3D

@export var walk_speed = 5.0
@export var sprint_speed = 7.5
@export var jump_velocity = 4.5
@export var sensitivity = 0.005
@export var view_bob = true
@export var bob_frequency = 2
@export var bob_amplitude = 0.08

var speed = walk_speed
var bob_t = 0.0

@onready var camera = $CameraPosition/Camera3D
@onready var camera_position = $CameraPosition

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		camera_position.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
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
	
	# head bob
	bob_t += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(bob_t)
	
	move_and_slide()

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_frequency) * bob_amplitude
	pos.x = cos(time * bob_frequency / 2) * bob_amplitude
	return pos
