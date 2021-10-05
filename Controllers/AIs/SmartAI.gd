extends RandomAI

class_name SmartAI



func get_movement_factor(ai_input=null):
	if ai_input[Boppie.Data.RAY_TYPE][0] == Boppie.Raytype.FOOD and ai_input[Boppie.Data.ENERGY] > 0.5:
		return 2
	return 1
	
	#{
	#	Energy: 0 - 1
	#	Boppie.Data.RAY_DIST: [0 - 1, 0 - 1]
	#	Boppie.Data.RAY_TYPE: [0 - 2, 0 - 2]
	#}
	
func get_turn_factor(ai_input=null):
	var types = ai_input[Boppie.Data.RAY_TYPE]
	var dists = ai_input[Boppie.Data.RAY_DIST]
	var closest_dist = 1
	if types[0] == Boppie.Raytype.FOOD:
		return 0
	for i in range(1, types.size()):
		if types[i] == Boppie.Raytype.FOOD:
			if dists[i] < closest_dist:
				closest_dist = dists[i]
				curr_turn_factor = 2 * ((i % 2) * 2 - 1)
				remaining_calls = 20 * int((i + 1) / 2)
				# break
	return .get_turn_factor(ai_input)
