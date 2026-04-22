extends Node3D

var timer = 10.0

@onready var display_label = $Control/DisplayLabel
@onready var level_manager = get_tree().current_scene
@onready var first_five_sfx = $FirstFivePlayer
@onready var second_five_sfx = $SecondFivePlayer
@onready var player = %CharacterBody3D
@onready var out_of_time_sfx = $OutOfTimePlayer

var int_time = int(timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if player.died or player.won:
		return
	
	timer -= delta
	display_label.text = str(int(timer) + 1)
	
	if timer <= 0:
		player.die()
		out_of_time_sfx.play()
	
	if int_time == (int(timer) + 1):
		
		if int_time > 5:
			first_five_sfx.play()
		else:
			second_five_sfx.play()
		
		int_time -= 1
