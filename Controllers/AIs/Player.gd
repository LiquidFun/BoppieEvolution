extends AI

class_name Player

func get_movement_factor():
	return Globals.input_vectors().y
	

func get_turn_factor():
	return -Globals.input_vectors().x
