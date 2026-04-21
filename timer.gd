extends Node3D

var timer = 10.0

@onready var display_label = $Control/DisplayLabel
@onready var level_manager = get_tree().current_scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	display_label.text = str(int(timer) + 1)
	
	# TEMP, replace with death screen
	if timer <= 0:
		level_manager.load_scene(level_manager.current_loaded_scene_id)
