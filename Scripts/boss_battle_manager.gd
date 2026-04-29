extends Node3D

const BOSS_BATTLE_INTRO = preload("uid://cexfggu4hk7mm")
const BOSS_BATTLE_PHASE_1_LOOP = preload("uid://xhp1hdnmcw1e")
const BOSS_BATTLE_PHASE_1_NO_DRUM_VARIANT = preload("uid://tcgabe41c3xx")
const BOSS_BATTLE_PHASE_2_INTRO = preload("uid://iq01xgrjkhbd")
const BOSS_BATTLE_PHASE_2_LOOP = preload("uid://b1cct1ik6id6m")

@onready var music_player: AudioStreamPlayer3D = $Music_Player

@onready var level_manager = get_tree().current_scene
@onready var main_music_player : AudioStreamPlayer3D = level_manager.get_child(0)
@onready var boss_body : StaticBody3D = $Boss/StaticBody3D
@onready var player = %CharacterBody3D
@onready var boss: Node3D = $Boss

@onready var current_stage = 1
@onready var current_audio_state = 0

@onready var pos_0: Node3D = $Pos0
@onready var pos_1: Node3D = $Pos1
@onready var pos_2: Node3D = $Pos2
@onready var pos_3: Node3D = $Pos3
@onready var pos_4: Node3D = $Pos4

var loop_1_played_times = 0

var health = 10

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
