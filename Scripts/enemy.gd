extends Node3D

@onready var area_3D = $Area3D
@onready var death_sfx = $DeathSound
@onready var shoot_sfx = $ShootSound
@onready var bullet_spawn_position = $ShootPoint
@onready var enemy_manager = get_parent()

var bullet_scene = preload("res://Prefab Scenes/enemy_bulllet.tscn")
var is_alive = true

@export var shoot_cooldown = 2.0
@export var shoot_timer = 1.0
@export var additional_random_time_mult = 0.5
@export var shooter_force = 60

# for hurt box
func _on_area_3d_body_entered(body: Node3D) -> void:
	die(body)

func _ready() -> void:
	shoot_timer = randf_range(1, 4)

func _process(delta: float) -> void:
	
	if !is_alive:
		return
	
	look_at(%CharacterBody3D.global_position, Vector3.UP)
	
	shoot_timer -= delta
	if shoot_timer <= 0:
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.position = bullet_spawn_position.global_position
		var rb = bullet.get_child(0)
		rb.apply_central_impulse(-bullet_spawn_position.global_transform.basis.z * shooter_force)
		shoot_timer = shoot_cooldown + (randf() * additional_random_time_mult)
		shoot_sfx.pitch_scale = randf_range(0.9, 1.2)
		shoot_sfx.play()

func die(body: Node3D = null, subtract_enemy_count: bool = true):
	area_3D.queue_free()
	
	if body != null:
		body.queue_free()
	
	is_alive = false
	
	if subtract_enemy_count:
		enemy_manager.update_enemy_count(-1)
		enemy_manager.update_text()
		death_sfx.play()
