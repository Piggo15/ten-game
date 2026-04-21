extends Node3D

var scene_list = []
var current_loaded_scene = null
var current_loaded_scene_id = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_list.append(preload("res://Scenes/main_menu.tscn"))
	scene_list.append(preload("res://Scenes/level_1.tscn"))
	
	load_scene(0)

func load_scene(scene_id):
	current_loaded_scene_id = scene_id
	
	if current_loaded_scene != null:
		current_loaded_scene.queue_free()
	
	current_loaded_scene = scene_list[scene_id].instantiate()
	add_child(current_loaded_scene)
