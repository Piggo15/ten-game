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
@onready var boss_body : Area3D = $Boss/Area3D
@onready var player = %CharacterBody3D
@onready var boss: Node3D = $Boss
@onready var teleport_timer: Timer = $TeleportTimer
@onready var pre_flash_timer: Timer = $PreFlashTimer
@onready var teleport_timer_2: Timer = $TeleportTimer2
@onready var pre_flash_timer_2: Timer = $PreFlashTimer2
@onready var tp_sound: AudioStreamPlayer3D = $Boss/TP_Sound
@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Node3D = $Boss/Area3D/Shoot_Point
@onready var shoot_sound: AudioStreamPlayer3D = $Boss/Shoot_Sound
@onready var health_bar: ColorRect = $Control/Health_Bar
@onready var start_timer: Timer = $Start_Timer
@onready var flash_before_phase_2_timer: Timer = $FlashBeforePhase2Timer
@onready var goon_spawn_timer: Timer = $GoonSpawnTimer

var current_stage = 1
var current_audio_state = 0

@onready var pos_0: Node3D = $Pos0
@onready var pos_1: Node3D = $Pos1
@onready var pos_2: Node3D = $Pos2
@onready var pos_3: Node3D = $Pos3
@onready var pos_4: Node3D = $Pos4

@onready var positions_to_teleport_to = [pos_1, pos_2, pos_3, pos_4]

@onready var goon_pos_1: Node3D = $GoonPos1
@onready var goon_pos_2: Node3D = $GoonPos2
@onready var goon_pos_3: Node3D = $GoonPos3
@onready var goon_pos_4: Node3D = $GoonPos4
@onready var goon_pos_5: Node3D = $GoonPos5
@onready var goon_pos_6: Node3D = $GoonPos6

@onready var goon_positions = [goon_pos_1, goon_pos_2, goon_pos_3, goon_pos_4, goon_pos_5, goon_pos_6]
const GOON = preload("uid://6f6gqhuxf2it")

var current_spawned_goon = 0

var current_pos = pos_0

var loop_1_played_times = 0

var health = 40
var max_health = 40

var teleport_cooldown = 3
var pre_teleport_time = 1
var pre_teleport_time_phase_2 = 0.5
var shot_cooldown = 0.5
var teleport_cooldown_phase_2 = 2
var shot_cooldown_phase_2 = 0.25
var shots_fired = 0
var shooter_force = 60
var shots_per_teleport = 4
var shots_per_teleport_phase_2 = 6

@onready var flash_ps: GPUParticles3D = $Boss/Flash_PS

func _ready() -> void:
	main_music_player.stop()
	music_player.stream = BOSS_BATTLE_INTRO
	music_player.play()
	music_player.finished.connect(_on_music_finished)
	update_health_bar()

func music_switcher():
	match current_audio_state:
		
		0:
			if music_player.playing:
				return
			music_player.stream = BOSS_BATTLE_PHASE_1_LOOP
			music_player.play()
			current_audio_state = 1
			loop_1_played_times = 1
		
		1:
			if music_player.playing:
				return
			if loop_1_played_times > 2:
				music_player.stream = BOSS_BATTLE_PHASE_1_NO_DRUM_VARIANT
				music_player.play()
				loop_1_played_times = 0
			else:
				music_player.stream = BOSS_BATTLE_PHASE_1_LOOP
				music_player.play()
				loop_1_played_times += 1
		2:
			if music_player.playing:
				return
			music_player.stream = BOSS_BATTLE_PHASE_2_INTRO
			music_player.play()
			current_audio_state = 3
		
		3:
			if music_player.playing:
				return
			music_player.stream = BOSS_BATTLE_PHASE_2_LOOP
			music_player.play()
			

func _on_music_finished():
	if player.died == true:
		return
	music_switcher()

func _process(_delta: float) -> void:
	boss_body.look_at (player.global_position, Vector3.UP)
	if player.died == true:
		music_player.stop()

func update_health_bar():
	health_bar.scale.x = float(health) / float(max_health)

func _on_start_timer_timeout() -> void:
	boss.position = pos_1.global_position
	current_pos = pos_1
	flash_ps.emitting = true
	teleport_timer.start(teleport_cooldown)
	tp_sound.play()
	shoot_timer.start(shot_cooldown)

func _on_teleport_timer_timeout() -> void:
	if player.died == true:
		return
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
	if player.died == true:
		return
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.position = shoot_point.global_position
	var rb = bullet.get_child(0)
	rb.apply_central_impulse(-shoot_point.global_transform.basis.z * shooter_force)
	shots_fired += 1
	shoot_sound.pitch_scale = randf_range(0.9, 1.2)
	shoot_sound.play()
	if shots_fired >= shots_per_teleport:
		shots_fired = 0
	else:
		shoot_timer.start(shot_cooldown)


func _on_area_3d_body_entered(body: Node3D) -> void:
	body.queue_free()
	health -= 1
	update_health_bar()
	if health <= 0:
		player.win()
	if (float(health) / float(max_health)) <= 0.5 and current_stage == 1:
		current_stage = 2
		current_audio_state = 2
		teleport_timer.stop()
		flash_ps.emitting = true
		tp_sound.play()
		start_timer.start(music_player.stream.get_length() - music_player.get_playback_position())
		teleport_cooldown = teleport_cooldown_phase_2
		shot_cooldown = shot_cooldown_phase_2
		shots_per_teleport = shots_per_teleport_phase_2
		pre_teleport_time = pre_teleport_time_phase_2
		shots_fired = shots_per_teleport
		flash_before_phase_2_timer.start(0.1)
		goon_spawn_timer.start(music_player.stream.get_length() - music_player.get_playback_position())


func _on_flash_before_phase_2_timer_timeout() -> void:
	boss.position = pos_0.global_position


func _on_goon_spawn_timer_timeout() -> void:
	var goon = GOON.instantiate()
	goon_positions[current_spawned_goon].add_child(goon)
	current_spawned_goon += 1
	if current_spawned_goon < 6:
		goon_spawn_timer.start(0.25)
