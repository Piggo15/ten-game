extends Node3D

var bob_frequency = 1
var bob_amplitude = 0.002
var t = 0

func _ready() -> void:
	t = randf_range(0, 3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	t += delta
	position.y += sin(bob_frequency * t) * bob_amplitude
