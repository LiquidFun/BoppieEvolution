extends AI

class_name NeuralNetwork



# Inputs:
var input_layer = (
	5 # ray food 
#   +1  # bias implicit
	+ 1 # a 5 second timer
#   1 # energy

#   5 # ray boppie
#   2 # previous inputs
#   ? # memory? from last n steps?
)

var output_layer = \
	2  # outputs

var weights = []
var layers = [input_layer, 3, output_layer]
var values = []

var thread = Thread.new()

func _init(parent_weights=null):
	if parent_weights == null:
		for layer in range(layers.size() - 1):
			weights.append([])
			for right in range(layers[layer+1]):
				weights[-1].append([])
				for left in range(layers[layer]+1):
					weights[-1][-1].append(randf() * 2 - 1)
	else:
		weights = parent_weights
	
	for layer in range(layers.size()):
		values.append([])
		for left in range(layers[layer]+1):
			values[-1].append(1)
	values[-1].pop_back()
			
	# print(layers)
	# print(weights)
	# print(values)
	
func get_mutated_weights(mutability):
	var weights2 = self.weights.duplicate(true)
	for layer in range(weights2.size()):
		for right in range(weights2[layer].size()):
			for left in range(weights2[layer][right].size()):
				var mutation = mutability * Globals.rng.randfn()
				# print(mutation)
				weights2[layer][right][left] += mutation
				
	return weights2
	
				
func calculate_inputs(ai_input):
	var dists = ai_input[Boppie.Data.RAY_DIST]
	var types = ai_input[Boppie.Data.RAY_TYPE]
	for i in range(dists.size()):
		values[0][i] = dists[i] if types[i] == ai_input[Boppie.Data.EATS] else 2.0
	values[0][5] = fmod(Globals.elapsed_time / 5.0, 1.0)
		
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
			values[layer+1][right] = relu(sum)

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
