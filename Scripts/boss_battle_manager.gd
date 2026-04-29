extends Node3D

const BOSS_BATTLE_INTRO = preload("uid://cexfggu4hk7mm")
const BOSS_BATTLE_PHASE_1_LOOP = preload("uid://xhp1hdnmcw1e")
const BOSS_BATTLE_PHASE_1_NO_DRUM_VARIANT = preload("uid://tcgabe41c3xx")
const BOSS_BATTLE_PHASE_2_INTRO = preload("uid://iq01xgrjkhbd")
const BOSS_BATTLE_PHASE_2_LOOP = preload("uid://b1cct1ik6id6m")

var bullet_scene = preload("res://Prefab Scenes/enemy_bulllet.tscn")

@onready var music_player: AudioStreamPlayer3D = $Music_Player

@onready var level_manager = get_tree().current_scene
@onready var main_music_player : AudioStreamPlayer3D = level_manager.get_child(0)
@onready var boss_body : StaticBody3D = $Boss/StaticBody3D
@onready var player = %CharacterBody3D
@onready var boss: Node3D = $Boss
@onready var teleport_timer: Timer = $TeleportTimer
@onready var pre_flash_timer: Timer = $PreFlashTimer
@onready var teleport_timer_2: Timer = $TeleportTimer2
@onready var pre_flash_timer_2: Timer = $PreFlashTimer2
@onready var tp_sound: AudioStreamPlayer3D = $Boss/TP_Sound
@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Node3D = $Boss/StaticBody3D/Shoot_Point
@onready var shoot_sound: AudioStreamPlayer3D = $Boss/Shoot_Sound

var current_stage = 1
var current_audio_state = 0

@onready var pos_0: Node3D = $Pos0
@onready var pos_1: Node3D = $Pos1
@onready var pos_2: Node3D = $Pos2
@onready var pos_3: Node3D = $Pos3
@onready var pos_4: Node3D = $Pos4

@onready var positions_to_teleport_to = [pos_1, pos_2, pos_3, pos_4]
var current_pos = pos_0

var loop_1_played_times = 0

var health = 10

var teleport_cooldown = 3
var pre_teleport_time = 1
var shot_cooldown = 0.5
var shots_fired = 0
var shooter_force = 60

@onready var flash_ps: GPUParticles3D = $Boss/Flash_PS

func _ready() -> void:
	main_music_player.stop()
	music_player.stream = BOSS_BATTLE_INTRO
	music_player.play()
	music_player.finished.connect(_on_music_finished)

func music_switcher():
	match current_audio_state:
		
		0:
			if !music_player.playing:
				music_player.stream = BOSS_BATTLE_PHASE_1_LOOP
				music_player.play()
				current_audio_state = 1
				loop_1_played_times = 1
		
		1:
			if !music_player.playing:
				if loop_1_played_times > 2:
					music_player.stream = BOSS_BATTLE_PHASE_1_NO_DRUM_VARIANT
					music_player.play()
					loop_1_played_times = 0
				else:
					music_player.stream = BOSS_BATTLE_PHASE_1_LOOP
					music_player.play()
					loop_1_played_times += 1

func _on_music_finished():
	music_switcher()

func _process(delta: float) -> void:
	boss_body.look_at (player.global_position, Vector3.UP)


func _on_start_timer_timeout() -> void:
	boss.position = pos_1.global_position
	current_pos = pos_1
	flash_ps.emitting = true
	teleport_timer.start(teleport_cooldown)
	tp_sound.play()
	shoot_timer.start(shot_cooldown)

func _on_teleport_timer_timeout() -> void:
	flash_ps.emitting = true
	pre_flash_timer.start(0.1)
	tp_sound.play()
	

func _on_pre_flash_timer_timeout() -> void:
	boss.position = pos_0.global_position
	teleport_timer_2.start(pre_teleport_time)

func _on_teleport_timer_2_timeout() -> void:
	var pos = positions_to_teleport_to[randi_range(0, positions_to_teleport_to.size() - 1)]
	while pos == current_pos:
		pos = positions_to_teleport_to[randi_range(0, positions_to_teleport_to.size() - 1)]
	boss.position = pos.global_position
	current_pos = pos
	pre_flash_timer_2.start(0.1)
	tp_sound.play()
	shoot_timer.start(shot_cooldown)

func _on_pre_flash_timer_2_timeout() -> void:
	flash_ps.emitting = true
	teleport_timer.start(teleport_cooldown)


func _on_shoot_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.position = shoot_point.global_position
	var rb = bullet.get_child(0)
	rb.apply_central_impulse(-shoot_point.global_transform.basis.z * shooter_force)
	shots_fired += 1
	shoot_sound.pitch_scale = randf_range(0.9, 1.2)
	shoot_sound.play()
	if shots_fired >= 3:
		shots_fired = 0
	else:
		shoot_timer.start(shot_cooldown)
