extends AI

class_name RandomAI

var curr_turn_factor = 0
var remaining_calls = 0

func get_movement_factor(ai_input=null):
	return 1
	

func get_turn_factor(ai_input=null):
	if remaining_calls <= 0:
		curr_turn_factor = randf() - .5
		remaining_calls = randi() % 200 + 20
	remaining_calls -= 1
	return curr_turn_factor
