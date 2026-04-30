extends Node3D

var enemy_node_array : Array[Node] = []
var enemy_count

@onready var enemy_count_label = $Control/EnemyCountLabel
@onready var player = %CharacterBody3D
@export var active = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !active:
		return
	
	for child in get_children():
		if child is Node3D:
			enemy_node_array.append(child)
	
	enemy_count = enemy_node_array.size()
	update_text()

func update_enemy_count(increment):
	enemy_count += increment
	if enemy_count == 0:
		player.win()

func update_text():
	enemy_count_label.text = "Enemies: " + str(enemy_count)

func clear_enemies():
	for enemy in enemy_node_array:
		if enemy.is_alive:
			enemy.die(null, false)
