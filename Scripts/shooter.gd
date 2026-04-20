extends Node3D

var bullet_scene = preload("res://Prefab Scenes/bulllet.tscn")
@export var shooter_force = 30
@onready var bullet_spawn_position = $"../CameraPosition/Camera3D/BulletSpawnPosition"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		var bullet = bullet_scene.instantiate()
		get_parent().get_parent().add_child(bullet)
		bullet.position = bullet_spawn_position.global_position
		var rb = bullet.get_child(0)
		rb.apply_central_impulse(-bullet_spawn_position.global_transform.basis.z * shooter_force)
