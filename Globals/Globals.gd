extends Node


var current_food_count = 0
var game_width = 2000
var game_height = 2000
var game_size = Vector2(game_width, game_height)

func input_vectors():
	var up_down = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	var left_right = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	var modifier = 1 + int(Input.is_action_pressed("ui_boost"))
	return Vector2(left_right, up_down) * modifier
