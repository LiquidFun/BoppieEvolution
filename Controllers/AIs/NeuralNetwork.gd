extends AI

class_name NeuralNetwork

# Inputs:
var input_layer = \
	5  # ray food
#   +1 # bias implicit

#   1 # a 1 second timer
#   1 # energy

#   5 # ray boppie
#   2 # previous inputs
#   ? # memory? from last n steps?

var output_layer = \
	2  # outputs

var layers = [input_layer, 3, output_layer]
var weights = []
var values = []

func _init():
	for layer in range(layers.size() - 1):
		weights.append([])
		for right in range(layers[layer+1]):
			weights[-1].append([])
			for left in range(layers[layer]+1):
				weights[-1][-1].append(randf() * 2 - 1)
	
	for layer in range(layers.size()):
		values.append([])
		for left in range(layers[layer]+1):
			values[-1].append(1)
	values[-1].pop_back()
			
	# print(layers)
	# print(weights)
	# print(values)
	
				
func calculate_inputs(ai_input):
	var dists = ai_input[Boppie.Data.RAY_DIST]
	var types = ai_input[Boppie.Data.RAY_TYPE]
	for i in range(dists.size()):
		values[0][i] = dists[i] if types[i] == Boppie.Raytype.FOOD else 2
		
func relu(num):
	return max(0, num)

func feed_forward(ai_input):
	calculate_inputs(ai_input)
	for layer in range(layers.size() - 1):
		for right in range(layers[layer+1]):
			var sum = 0
			for left in range(layers[layer]+1):
				sum += weights[layer][right][left] * values[layer][left]
			values[layer+1][right] = relu(sum)

func get_movement_factor(ai_input=null):
	feed_forward(ai_input)
	# print(values[-1])
	# print(values[0])
	return values[-1][0]
	

func get_turn_factor(ai_input=null):
	return values[-1][1]
