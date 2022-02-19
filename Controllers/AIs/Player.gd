extends AI

class_name Player

func get_movement_factor(_ai_input=null):
	return Utils.input_vectors().y
	

func get_turn_factor(_ai_input=null):
	return -Utils.input_vectors().x
