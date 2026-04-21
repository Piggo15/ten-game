extends Node3D

@onready var area_3D = $Area3D
@onready var death_sfx = $DeathSound

func _on_area_3d_body_entered(body: Node3D) -> void:
	area_3D.queue_free()
	body.queue_free()
	death_sfx.play()
