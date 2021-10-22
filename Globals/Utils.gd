extends Node


func input_vectors():
	var up_down = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	var left_right = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	var modifier = 1 + int(Input.is_action_pressed("boost_movement")) * 10
	return Vector2(left_right, up_down) * modifier

func iso_datetime():
	var d = OS.get_datetime()
	return "%02d-%02d-%02dT%02d:%02d:%02d" % [
		d["year"],
		d["month"],
		d["day"],
		d["hour"],
		d["minute"],
		d["second"],
	]
