extends AI

class_name NeuralNetwork



# Inputs:
var input_layer = (
	5 # ray food 
#   + 1  # bias implicit
#	+ 1 # a 5 second timer
#   1 # energy

#   5 # ray boppie
#   2 # previous inputs
#	+ 1 # memory? from last n steps?
#	+ 4 # danger sense
)

var output_layer = \
	2  # outputs

var weights = []
var layers = [input_layer, output_layer]
var values = []

var thread = Thread.new()

func _init(parent_weights=null):
	if parent_weights == null:
		for layer in range(layers.size() - 1):
			weights.append([])
			for right in range(layers[layer+1]):
				weights[-1].append([])
				for left in range(layers[layer]+1):
					weights[-1][-1].append(Globals.rng.randf() * 2 - 1)
	else:
		weights = parent_weights
	
	for layer in range(layers.size()):
		values.append([])
		for left in range(layers[layer]+1):
			values[-1].append(1)
	values[-1].pop_back()


func mutate(property, mutability):
	if property == "weights":
		mutate_weights(mutability)
	
func mutate_weights(mutability):
	for layer in range(weights.size()):
		for right in range(weights[layer].size()):
			for left in range(weights[layer][right].size()):
				var mutation = mutability * Globals.rng.randfn()
				weights[layer][right][left] += mutation
	
				
func calculate_inputs(ai_input):
	var dists = ai_input[Boppie.Data.RAY_DIST]
	var types = ai_input[Boppie.Data.RAY_TYPE]
	for i in range(dists.size()):
		values[0][i] = 1 - dists[i] / 2 if types[i] == ai_input[Boppie.Data.EATS] else 0.0
	#values[0][5] = values[1][2]
	# print(ai_input[Boppie.Data.DANGER_SENSE])
	#for i in range(4):
	#	var danger = ai_input[Boppie.Data.DANGER_SENSE][i]
	#	values[0][6 + i] = 0.0 if danger == 1.0 else 1.0 - danger / 2.0
	#values[0][5] = fmod(Globals.elapsed_time / 5.0, 1.0)
		
func relu(num):
	return max(0, num)

func feed_forward(ai_input):
	calculate_inputs(ai_input)
	#if ai_input[Boppie.Data.EATS] == Boppie.Raytype.OWLIE:
	#	print(values )
	for layer in range(layers.size() - 1):
		for right in range(layers[layer+1]):
			var sum = 0
			for left in range(layers[layer]+1):
				sum += weights[layer][right][left] * values[layer][left]
			values[layer+1][right] = sum if layers.size() - 1 == layer + 1 else relu(sum)

func get_movement_factor(ai_input=null):
	if thread.is_active():
		thread.wait_to_finish()
	thread.start(self, "feed_forward", ai_input)
	# feed_forward(ai_input)
	return values[-1][0]
	

func get_turn_factor(ai_input=null):
	return values[-1][1]

func _exit_tree():
	thread.wait_to_finish()
