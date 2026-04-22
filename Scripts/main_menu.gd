extends Node3D

@onready var level_manager = get_tree().current_scene

@export var credits_scene_id = 1
@export var level_1_scene_id = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	level_manager.load_scene(level_1_scene_id)


func _on_credits_button_pressed() -> void:
	level_manager.load_scene(credits_scene_id)
