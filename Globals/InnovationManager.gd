extends Node

var innovation_id = 0
# 0th element is ignored 
var innovations: Array = [["Input", "Output"]]
var common_innovation_ids: Array = []
var fully_connected_neurons: int = 0
var max_ray_count_additional = 2
var danger_sense_parts = 4
var nn_input_neurons = get_nn_input_neurons()
var nn_output_neurons = ["Move", "Turn"]

func add_innovation(input: String, output: String) -> int:
	innovation_id += 1
	common_innovation_ids.append(innovation_id)
	innovations.append([input, output])
	return innovation_id
	
func get_nn_input_neurons():
	var input_neurons = []
	for i in range(1 + 2 * max_ray_count_additional):
		input_neurons.append("VisionRayEats" + str(i))
	for i in range(danger_sense_parts):
		input_neurons.append("DangerSense" + str(i))
	input_neurons.append("Bias")
	return input_neurons

func _ready() -> void:
	make_initial_innovations(nn_input_neurons)
	
func make_initial_innovations(inputs):
	if fully_connected_neurons > 0:
		var hidden_neurons = []
		for i in range(fully_connected_neurons):
			hidden_neurons.append("HiddenNeuron" + str(i))
		for hidden_neuron in hidden_neurons:
			for input in inputs:
				add_innovation(input, hidden_neuron)
		inputs = hidden_neurons + ["Bias"]
	for output_neuron in nn_output_neurons:
		for input in inputs:
			add_innovation(input, output_neuron)
