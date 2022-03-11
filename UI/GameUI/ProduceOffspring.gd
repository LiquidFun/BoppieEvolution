extends Button

onready var game_controller = get_tree().get_nodes_in_group("GameController")[0]

func _on_ProduceOffspring_pressed() -> void:
	game_controller.produce_and_focus_offspring()
