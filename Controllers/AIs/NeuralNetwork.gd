extends AI

class_name NeuralNetwork

class NN_DNA:
	var connections = {}
	var innovations = []
	

var input_neuron_count
var output_neurons_from
var neuron_name_to_index: Dictionary
var neuron_index_to_name: Dictionary
var connections_internal
var dna = NN_DNA.new() setget set_dna
var values = []
var move_value_index
var turn_value_index

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

# neuron_name_to_index is provided to lookup the integer from the string name

func set_dna(new_dna):
	# dna = new_dna.copy()
	dna.connections = new_dna.connections.duplicate(true)
	dna.innovations = new_dna.innovations.duplicate(true)
	recalculate_internal_connections()


func recalculate_internal_connections():
	self.connections_internal = []
	self.neuron_name_to_index = {}
	self.neuron_index_to_name = {}
	self.values.clear()
	input_neuron_count = len(InnovationManager.nn_input_neurons)
	for output in InnovationManager.nn_input_neurons + dna.connections.keys():
		if not (output in neuron_name_to_index):
			neuron_name_to_index[output] = len(neuron_name_to_index)
			values.append(int(output == "Bias"))
			for input in dna.connections[output]:
				if not (input in neuron_name_to_index):
					neuron_name_to_index[input] = len(neuron_name_to_index)
					values.append(int(input == "Bias"))
	for key in neuron_name_to_index:
		neuron_index_to_name[neuron_name_to_index[key]] = key
	move_value_index = neuron_name_to_index["Move"]
	turn_value_index = neuron_name_to_index["Turn"]
			
	for output in dna.connections:
		var connect_into = dna.connections[output]
		connections_internal.append([neuron_name_to_index[output], []])
		for key in connect_into:
			connections_internal[-1][1].append(neuron_name_to_index[key])
			connections_internal[-1][1].append(connect_into[key])
		
	
func random_weight():
	return Globals.rng.randf() * 2.0 - 1.0
	
func get_weight_for_innovation(innovation_id):
	# TODO: change to connections_internal? connections weights might not be right
	var innovation = InnovationManager.innovations[innovation_id]
	return dna.connections[innovation[1]][innovation[0]]
	

func add_innovation_to_dictionary(innovation_id):
	dna.innovations.append(innovation_id)
	if innovation_id < 0: # Don't add negative innovation ids
		return
	var innovation = InnovationManager.innovations[innovation_id]
	var input = innovation[0]
	var output = innovation[1]
	if not (output in dna.connections) and not (output in InnovationManager.nn_input_neurons):
		dna.connections[output] = {"Bias": random_weight()}
	dna.connections[output][input] = random_weight()
	
func make_and_merge_nns(fitter_innovations, other_innovations=[]):
	if other_innovations == null:
		other_innovations = []
	dna.innovations = []
	dna.connections = {}
	for input in InnovationManager.nn_input_neurons:
		dna.connections[input] = {}
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
	self.make_and_merge_nns(fitter_innovations, other_innovations)
	# init_connections(inputs, fully_connected_neurons)
	
func crossover(property, other_dna):
	if property == "dna":
		make_and_merge_nns(dna.innovations, other_dna.innovations)
		crossover_connections(other_dna.connections)
	
func crossover_connections(other_connections):
	var old_connections = dna.connections
	self.make_and_merge_nns(dna.innovations)
	print(old_connections)
	print("---")
	print(other_connections)
	print("---")
	print(dna.connections)
	print()
	print()
	print()
	if other_connections == null:
		other_connections = {}
	for output in dna.connections:
		for input in dna.connections[output]:
			var old = old_connections.get(output, {}).get(input, null)
			var other = other_connections.get(output, {}).get(input, null)
			if old != null and other != null:
				dna.connections[output][input] = old if Globals.rng.randf() < 0.5 else other
			elif old != null:
				dna.connections[output][input] = old
			elif other != null:
				dna.connections[output][input] = other
			else:
				dna.connections[output][input] = random_weight()
	recalculate_internal_connections()


func mutate(property, mutability):
	if property == "dna":
		mutate_structure(1)
		mutate_weights(mutability)
	
		
func add_random_connection():
	var inputs = InnovationManager.nn_input_neurons.duplicate()
	var outputs = InnovationManager.nn_output_neurons.duplicate()
	for key in dna.connections:
		if not (key in inputs) and not (key in outputs):
			inputs.push_back(key)
			outputs.push_back(key)
	var input
	var output
	for tries in range(10): # 10 tries max
		input = inputs[Globals.rng.randi() % len(inputs)]
		output = outputs[Globals.rng.randi() % len(outputs)]
		# Assert that the connection does not exist in either direciton
		if dna.connections.get(input, {}).get(output, null) == null:
			if dna.connections.get(output, {}).get(input, null) == null:
				add_new_connection(input, output)
				recalculate_internal_connections()
				return
	
func add_new_connection(input, output, weight=null):
	dna.innovations.append(InnovationManager.add_innovation(input, output))
	if weight == null:
		weight = random_weight()
	if not (output in dna.connections):
		dna.connections[output] = {"Bias": random_weight()}
	dna.connections[output][input] = weight
	
func add_hidden_neuron():
	# Replace some connection with a hidden neuron and 2 connections to it, disabling the old one
	for i in range(10):
		var name = "HiddenNeuron" + str(i)
		if name in dna.connections:
			continue
		
		for j in range(10): # Try randomly some innovations
			var local_innovation_index = Globals.rng.randi() % len(dna.innovations)
			var innovation = dna.innovations[local_innovation_index]
			if innovation > 0: # Check whether innovation is enabled
				dna.innovations[local_innovation_index] *= -1 # Disable innovation
				var input_output = InnovationManager.innovations[innovation]
				var weight = dna.connections[input_output[1]][input_output[0]]
				dna.connections[name] = {"Bias": random_weight() * .1}
				add_new_connection(input_output[0], name, weight)
				add_new_connection(name, input_output[1], weight)
				recalculate_internal_connections()
				return
		

func remove_random_connection():
	var i
	for tries in range(10): # 10 tries max, as while true may never end
		i = Globals.rng.randi() % len(dna.innovations)
		if dna.innovations[i] > 0:
			break
	dna.innovations[i] *= -1
		
func mutate_structure(mutability):
	# Mutate structure by: deleting and adding connections/neurons
	if Globals.rng.randf() < mutability:
		var chances = [[0.7, "add"], [0, "remove"], [1, "new"]]
		var chance = Globals.rng.randf()
		for list in chances:
			if chance <= list[0]:
				match list[1]:
					"add": add_random_connection()
					# "remove": remove_random_connection()
					"new": add_hidden_neuron()
				break
	
func mutate_weights(mutability):
	for connection in connections_internal:
		var output = neuron_index_to_name[connection[0]]
		for i in range(0, len(connection[1]), 2):
			var mutation = mutability * Globals.rng.randfn()
			connection[1][i+1] += mutation
			var input = neuron_index_to_name[connection[1][i]]
			dna.connections[output][input] += mutation

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
	return values[move_value_index]
	

func get_turn_factor(ai_input=null):
	return values[turn_value_index]

#func _exit_tree():
#	thread.wait_to_finish()
