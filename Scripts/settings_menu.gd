extends Control

@onready var level_manager = get_tree().current_scene
@onready var settings_manager = get_tree().current_scene.get_child(1)
@onready var h_slider_sensitivity: HSlider = $HSlider_Sensitivity
@onready var h_slider_sfx_volume: HSlider = $HSlider_Sfx_Volume
@onready var h_slider_music_volume: HSlider = $HSlider_Music_Volume
@onready var h_slider_master_volume: HSlider = $HSlider_Master_Volume
@onready var check_box_vsync: CheckBox = $CheckBox_Vsync

func _ready() -> void:
	h_slider_sensitivity.value = settings_manager.sensitivity
	
	h_slider_sfx_volume.value = settings_manager.sfx_volume
	h_slider_music_volume.value = settings_manager.music_volume
	h_slider_master_volume.value = settings_manager.master_volume
	check_box_vsync.button_pressed = settings_manager.vsync

func _on_back_to_main_menu_pressed() -> void:
	level_manager.load_scene(0)

func _on_h_slider_sensitivity_value_changed(value: float) -> void:
	settings_manager.sensitivity = h_slider_sensitivity.value 

func _on_h_slider_master_volume_value_changed(value: float) -> void:
	settings_manager.master_volume = h_slider_master_volume.value 
	settings_manager.update_audio_busses()

func _on_h_slider_sfx_volume_value_changed(value: float) -> void:
	settings_manager.sfx_volume = h_slider_sfx_volume.value 
	settings_manager.update_audio_busses()

func _on_h_slider_music_volume_value_changed(value: float) -> void:
	settings_manager.music_volume = h_slider_music_volume.value
	settings_manager.update_audio_busses()

func _on_check_box_vsync_pressed() -> void:
	settings_manager.vsync = check_box_vsync.button_pressed
	settings_manager.update_vsync()
