extends Node3D

@onready var level_manager : Node3D = get_parent()
@onready var control: Control = $Control

var paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if level_manager.current_loaded_scene_id < level_manager.level_1_scene_id:
		return
	
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	
	if Input.is_action_just_pressed("pause"):
		pause()

func pause():
	control.visible = true
	Engine.time_scale = 0.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	paused = true

func _on_resume_button_pressed() -> void:
	control.visible = false
	Engine.time_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	paused = false


func _on_main_menu_button_pressed() -> void:
	level_manager.load_scene(0)
	control.visible = false
	Engine.time_scale = 1.0
	paused = false
