extends Node3D

@onready var level_manager = get_tree().current_scene
@onready var config_file = ConfigFile.new()

var path = "user://config.cfg"

var sensitivity = 0.005

var sfx_volume = 1.0
var music_volume = 1.0
var master_volume = 1.0

var vsync = true

func _ready() -> void:
	load_config()

func _exit_tree() -> void:
	save_config()

func load_config():
	var loaded = config_file.load(path)
	if loaded != OK:
		return
	
	sensitivity = config_file.get_value("Input Settings", "sensitivity") if config_file.get_value("Input Settings", "sensitivity") != null else sensitivity
	sfx_volume = config_file.get_value("Audio Settings", "sfx_volume") if config_file.get_value("Audio Settings", "sfx_volume") != null else sfx_volume
	music_volume = config_file.get_value("Audio Settings", "music_volume") if config_file.get_value("Audio Settings", "music_volume") != null else music_volume
	master_volume = config_file.get_value("Audio Settings", "master_volume") if config_file.get_value("Audio Settings", "master_volume") != null else master_volume
	vsync = config_file.get_value("Video Settings", "vsync") if config_file.get_value("Video Settings", "vsync") != null else vsync
	update_audio_busses()
	update_vsync()


func save_config():
	config_file.set_value("Input Settings", "sensitivity", sensitivity)
	config_file.set_value("Audio Settings", "sfx_volume", sfx_volume)
	config_file.set_value("Audio Settings", "music_volume", music_volume)
	config_file.set_value("Audio Settings", "master_volume", master_volume)
	config_file.set_value("Video Settings", "vsync", vsync)
	config_file.save(path)

func update_audio_busses():
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(1, linear_to_db(sfx_volume))
	AudioServer.set_bus_volume_db(2, linear_to_db(music_volume))

func update_vsync():
	if vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	print("Vsync " + str(DisplayServer.window_get_vsync_mode()) + str(vsync))
