extends AI

class_name NeuralNetwork

var input_neuron_count
var output_neurons_from
var neuron_index_lookup
var connections = [] setget set_connections
var connections_internal
var values = []


func set_connections(new_connections):
	connections = new_connections
	neuron_index_lookup = {}
	connections_internal = []
	values.clear()
	for index in range(len(connections)):
		var connection = connections[index]
		neuron_index_lookup[connection[0]] = index
		connections_internal.append([index, []])
		for key in connection[1]:
			connections_internal[-1][1].append(neuron_index_lookup[key])
			connections_internal[-1][1].append(connection[1][key])
		values.append(int(connection[0] == "Bias"))
	
func get_weights_dict(names):
	var weights = {}
	for curr_name in names:
		weights[curr_name] = Globals.rng.randf() * 2.0 - 1.0
	return weights
	
func init_connections(inputs, fully_connected_neurons=-1):
	var conn = []
	input_neuron_count = len(inputs)
	for input_neuron_name in inputs:
		conn.append([input_neuron_name, {}])
	if fully_connected_neurons > 0:
		var hidden_neurons = []
		for i in range(fully_connected_neurons):
			hidden_neurons.append("HiddenNeuron" + str(i))
		
		for hidden_neuron in hidden_neurons:
			conn.append([hidden_neuron, get_weights_dict(inputs)])
		inputs = hidden_neurons + ["Bias"]
	if fully_connected_neurons >= 0:
		for output_neuron in ["Move", "Turn"]:
			conn.append([output_neuron, get_weights_dict(inputs)])
	self.connections = conn


func _init(inputs=[], fully_connected_neurons=3):
	init_connections(inputs, fully_connected_neurons)


func mutate(property, mutability):
	if property == "weights":
		mutate_weights(mutability)
	
func mutate_weights(mutability):
	for connection in connections_internal:
		for i in range(0, len(connection[1]), 2):
			var mutation = mutability * Globals.rng.randfn()
			connection[1][i+1] += mutation

func relu(num):
	return max(0, num)

func feed_forward():
	for i in range(input_neuron_count, len(connections_internal)):
		var conn = connections_internal[i]
		var new_value := 0.0
		for j in range(0, len(conn[1]), 2):
			new_value += values[conn[1][j]] * conn[1][j+1]
		values[conn[0]] = new_value if i >= len(connections_internal) - 2 else relu(new_value)

func get_movement_factor(ai_input=null):
	#if thread.is_active():
	#	thread.wait_to_finish()
	#thread.start(self, "feed_forward", ai_input)
	# feed_forward(ai_input)
	feed_forward()
	return values[-2]
	

func get_turn_factor(ai_input=null):
	return values[-1]

#func _exit_tree():
#	thread.wait_to_finish()
