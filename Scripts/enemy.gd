extends Node3D

@onready var area_3D = $Area3D
@onready var death_sfx = $DeathSound
@onready var shoot_sfx = $ShootSound
@onready var bullet_spawn_position = $ShootPoint

var bullet_scene = preload("res://Prefab Scenes/enemy_bulllet.tscn")
var is_alive = true

@export var shoot_cooldown = 2.0
@export var shoot_timer = 1.0
@export var additional_random_time_mult = 0.5
@export var shooter_force = 60

# for hurt box
func _on_area_3d_body_entered(body: Node3D) -> void:
	area_3D.queue_free()
	body.queue_free()
	death_sfx.play()
	is_alive = false

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
