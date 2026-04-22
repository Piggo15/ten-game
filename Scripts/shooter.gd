extends Node3D

var bullet_scene = preload("res://Prefab Scenes/bulllet.tscn")

@export var shooter_force = 60
@export var ammo_amount = 10

@onready var bullet_spawn_position = $"../CameraPosition/Camera3D/BulletSpawnPosition"
@onready var sfx_player = $ShootSound
@onready var ammo_label  = $"../Control/AmmoLabel"
@onready var player = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot") and ammo_amount > 0 and !player.died and !player.won:
		var bullet = bullet_scene.instantiate()
		get_parent().get_parent().add_child(bullet)
		bullet.position = bullet_spawn_position.global_position
		var rb = bullet.get_child(0)
		rb.apply_central_impulse(-bullet_spawn_position.global_transform.basis.z * shooter_force)
		sfx_player.pitch_scale = randf_range(0.9, 1.2)
		sfx_player.play()
		ammo_amount -= 1
		ammo_label.text = "Ammo: " + str(ammo_amount) + "/10"
