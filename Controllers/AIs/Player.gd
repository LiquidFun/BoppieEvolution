extends AI

class_name Player

func get_movement_factor():
	var movement = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	return movement
	

func get_turn_factor():
	var rotation = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	return rotation
