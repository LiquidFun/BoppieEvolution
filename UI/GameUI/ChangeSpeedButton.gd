extends Button

export var factor: float = 0.5
onready var game_controller = get_tree().get_nodes_in_group("GameController")[0]


func _on_ChangeSpeedButton_pressed() -> void:
	if factor == 0:
		
		game_controller.toggle_simulation_pause()
		if get_tree().paused:
			self.text = ""  # play
		else:
			self.text = ""  # pause
	else:
		game_controller.change_time_scale(factor)
