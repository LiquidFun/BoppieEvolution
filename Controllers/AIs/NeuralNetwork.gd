extends AI

class_name NeuralNetwork

var input_neuron_count
var output_neurons_from
var neuron_index_lookup: Dictionary
var connections = {} setget set_connections
var connections_internal
var values = []
var innovations = []

# old:
# connections: List[Tuple[str (name), Dict[str (name), float (weight)]]
# e.g.: [[VisionRayEats0, {}], [Move, {Bias:0.647106, DangerSense0:-0.622663}], ...].

# connections: Dict[str (name), Dict[str (name), float (weight)]]
# e.g.: {VisionRayEats0:{}, Move:{Bias:0.647106, DangerSense0:-0.622663}, ...}
# Connects neurons with previous neurons, specifying the weight of the connection

# connections_internal: List[Tuple[int, List[alternating int / float]]]
# e.g.: [[0, []], [11, [1, 0.647106, 13, -0.622663]], ...]
# It represents the same information as in 'connections', however to 
# improve performance this is written such that string comparisons
# need not be done and instead of a Dictionary, the List can 
# traversed linearly in steps of 2. This was by far the largest
# bottleneck, so some readability is sacrificed.

# neuron_index_lookup is provided to lookup the integer from the string name


func set_connections(new_connections):
	connections = new_connections
	recalculate_internal_connections()
	
func recalculate_internal_connections():
	self.connections_internal = []
	self.neuron_index_lookup = {}
	self.values.clear()
	var index = 0 # no enumerate unfortunately
	input_neuron_count = len(InnovationManager.nn_input_neurons)
	for input in InnovationManager.nn_input_neurons:
		if not (input in neuron_index_lookup):
			neuron_index_lookup[input] = index
			values.append(int(input == "Bias"))
			index += 1
	for output in connections:
		if not (output in neuron_index_lookup):
			neuron_index_lookup[output] = index
			values.append(int(output == "Bias"))
			index += 1
			
	for output in connections:
		var connect_into = connections[output]
		connections_internal.append([neuron_index_lookup[output], []])
		for key in connect_into:
			connections_internal[-1][1].append(neuron_index_lookup[key])
			connections_internal[-1][1].append(connect_into[key])
		
	
func get_weights_dict(names):
	var weights = {}
	for curr_name in names:
		weights[curr_name] = random_weight()
	return weights
	
func random_weight():
	return Globals.rng.randf() * 2.0 - 1.0
	
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
	
func add_innovation_to_dictionary(innovation_id):
	self.innovations.append(innovation_id)
	if innovation_id < 0: # Don't add negative innovation ids
		return
	var innovation = InnovationManager.innovations[innovation_id]
	var input = innovation[0]
	var output = innovation[1]
	if not (output in connections):
		connections[output] = {}
	connections[output][input] = random_weight()
	
func make_and_merge_innovations(fitter_innovations, other_innovations=[]):
	connections = {}
	for input in InnovationManager.nn_input_neurons:
		connections[input] = {}
	var i1 = 0
	var i2 = 0
	while i1 < len(fitter_innovations) or i2 < len(other_innovations):		
		if i2 >= len(other_innovations):
			add_innovation_to_dictionary(fitter_innovations[i1])
			i1 += 1
			continue
		if i1 >= len(fitter_innovations):
			add_innovation_to_dictionary(other_innovations[i2])
			i2 += 1
			continue
		var id1 = fitter_innovations[i1]
		var id2 = other_innovations[i2]
		if abs(id1) == abs(id2):
			# Add id1 without abs, since it overwrites id2
			add_innovation_to_dictionary(id1)
			i1 += 1
			i2 += 1
		elif abs(id1) != abs(id2):
			if abs(id1) > abs(id2):
				add_innovation_to_dictionary(id1)
				i1 += 1
			else:
				add_innovation_to_dictionary(id2)
				i2 += 1
	recalculate_internal_connections()
			


func _init(fitter_innovations, other_innovations=[]):
	self.make_and_merge_innovations(fitter_innovations, other_innovations)
	# init_connections(inputs, fully_connected_neurons)


func mutate(property, mutability):
	if property == "weights":
		mutate_weights(mutability)
		mutate_structure(mutability)
		
func mutate_structure(mutability):
	# Mutate structure by: deleting and adding connections/neurons
	pass
	
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
