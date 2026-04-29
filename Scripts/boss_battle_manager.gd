extends Node3D

const BOSS_BATTLE_INTRO = preload("uid://cexfggu4hk7mm")
const BOSS_BATTLE_PHASE_1_LOOP = preload("uid://xhp1hdnmcw1e")
const BOSS_BATTLE_PHASE_1_NO_DRUM_VARIANT = preload("uid://tcgabe41c3xx")
const BOSS_BATTLE_PHASE_2_INTRO = preload("uid://iq01xgrjkhbd")
const BOSS_BATTLE_PHASE_2_LOOP = preload("uid://b1cct1ik6id6m")

@onready var music_player: AudioStreamPlayer3D = $Music_Player

@onready var level_manager = get_tree().current_scene
@onready var main_music_player : AudioStreamPlayer3D = level_manager.get_child(0)

@onready var current_stage = 1
@onready var current_audio_state = 0

var loop_1_played_times = 0

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
				var random = randi_range(0, 3) # 25% chance to play other clip
				if random == 0 and loop_1_played_times > 3:
					music_player.stream = BOSS_BATTLE_PHASE_1_NO_DRUM_VARIANT
					music_player.play()
					loop_1_played_times = 1
				else:
					music_player.stream = BOSS_BATTLE_PHASE_1_LOOP
					music_player.play()
					loop_1_played_times += 1

func _on_music_finished():
	music_switcher()
