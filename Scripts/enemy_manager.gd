extends Node3D

var enemy_node_array : Array[Node] = []
@onready var enemy_count_label = $Control/EnemyCountLabel
var enemy_count

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Node3D:
			enemy_node_array.append(child)
	
	enemy_count = enemy_node_array.size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	enemy_count_label.text = "Enemies: " + str(enemy_count)
