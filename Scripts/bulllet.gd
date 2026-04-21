extends Node3D

var time_active = 0
var despawn_time = 3

@onready var rb = $RigidBody3D

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	time_active += delta
	
	if time_active >= despawn_time:
		queue_free()
