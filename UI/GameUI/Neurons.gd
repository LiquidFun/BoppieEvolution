extends PanelContainer

var neural_network = null setget set_neural_network
var height := 250.0
var width := 400.0
var neuron_radius := 15
var margins = neuron_radius * 3
var neuron_dist = neuron_radius * 3
var font = get_font("font") 
var neuron_weight_gradient: Gradient = load("res://UI/GameUI/NeuronWeight.tres")
var depth_map = {}
var layers = []

func calculate_depth_map():
	depth_map = {}
	var max_depth = 0
	for connection in neural_network.connections_internal:
		depth_map[connection[0]] = 2
	for connection in InnovationManager.nn_input_neurons:
		depth_map[neural_network.neuron_name_to_index[connection]] = 1
	for connection in neural_network.connections_internal:
		if neural_network.neuron_index_to_name[connection[0]] in InnovationManager.nn_output_neurons:
			continue
		depth_map[connection[0]] = 1
		for i in range(0, len(connection[1]), 2):
			depth_map[connection[0]] = max(depth_map[connection[1][i]]+1, depth_map[connection[0]])
		max_depth = max(max_depth, depth_map[connection[0]])
	for connection in InnovationManager.nn_output_neurons:
		depth_map[neural_network.neuron_name_to_index[connection]] = max_depth + 1
	layers = []
	for key in depth_map:
		while layers.size() < depth_map[key]:
			layers.append([])
		layers[depth_map[key]-1].append(key)

func _ready():
	self.rect_min_size = Vector2(width, height)

func set_neural_network(nn):
	neural_network = nn
	if neural_network != null:
		calculate_depth_map()
		for layer in layers:
			self.height = max(height, (layer.size() - 1) * neuron_dist + margins * 2)
			rect_min_size = Vector2(width, height)
		self.update()
	
func _process(delta):
	update()

func _draw():
	if neural_network == null:
		return
	var values = neural_network.values
	var connections = neural_network.connections_internal
	var inside_height = height - margins * 2
	var inside_width = width - margins * 2
	var xs = []
	var start_ys = []
	
	# Calculate offsets
	for layer in range(layers.size()):
		xs.append(margins + layer * inside_width / (layers.size() - 1))
		start_ys.append(margins + (inside_height / 2) - ((layers[layer].size() - 1) * neuron_dist) / 2)
		
	# Neuron index to position lookup
	var lookup_index_to_pos = {}
	for layer in range(layers.size()):
		for neuron in range(layers[layer].size()):
			var y = start_ys[layer] + neuron * neuron_dist
			lookup_index_to_pos[layers[layer][neuron]] = Vector2(xs[layer], y)
		
	# Draw connections between neurons
	for connection in connections:
		var right_pos = lookup_index_to_pos[connection[0]]
		for i in range(0, len(connection[1]), 2):
			var left_pos = lookup_index_to_pos[connection[1][i]]
			var weight = connection[1][i+1]
			var dendron = weight * values[connection[1][i]]
			var color = neuron_weight_gradient.interpolate((weight + 1) / 2.0)
			# var color = Color.white
			draw_line(left_pos, right_pos, color, abs(weight * 3))

	# Draw neurons
	for index in lookup_index_to_pos:
		var pos = lookup_index_to_pos[index]
		var text_pos = pos + Vector2(-neuron_radius * .7, neuron_radius * .4)
		var value = clamp((values[index] + 1) / 3.0, 0, 1)
		draw_circle(pos, neuron_radius, Color.darkolivegreen.lightened(value))
		draw_string(font, text_pos, "%.1f" % values[index], Color.black)
		
	# Calculate positions of help-banners explaining neuron meaning
	var input_neurons = neural_network.neuron_index_to_name
	var neuron_group_ranges = Dictionary()
	for layer_index in [0, -1]:
		var first_index = 0
		var layer = layers[layer_index]
		for index in range(0, len(layer)):
			var similarity = input_neurons[layer[index]].similarity(input_neurons[layer[first_index]])
			if similarity < .4:
				first_index = index
			var upper_pos = lookup_index_to_pos[layer[index]]
			var lower_pos = lookup_index_to_pos[layer[first_index]]
			var start_or_end_factor = -1 if layer_index == 0 else 1
			var add_x = (neuron_radius + 5) * start_or_end_factor
			upper_pos += Vector2(add_x, neuron_radius)
			lower_pos += Vector2(add_x, -neuron_radius)
			var text = input_neurons[layer[index]].rstrip("0123456789")
			neuron_group_ranges[text] = [upper_pos, lower_pos, start_or_end_factor]

	# Draw lines for the help banners
	for text in neuron_group_ranges:
		var upper_lower_pos = neuron_group_ranges[text]
		draw_line(upper_lower_pos[0], upper_lower_pos[1], Color(1, 1, 1), 1, true)
		var divets =  Vector2(-5, 0) * upper_lower_pos[2]
		draw_line(upper_lower_pos[0], upper_lower_pos[0] + divets, Color(1, 1, 1), 1, true)
		draw_line(upper_lower_pos[1], upper_lower_pos[1] + divets, Color(1, 1, 1), 1, true)
		
	# Draw text for the help banners
	for text in neuron_group_ranges:
		var upper_lower_pos = neuron_group_ranges[text]
		var text_pos = (upper_lower_pos[0] + upper_lower_pos[1]) / 2
		text_pos -= Vector2(-3, 7 * len(text) / 2) * upper_lower_pos[2]
		draw_set_transform(text_pos, upper_lower_pos[2] * PI/2, Vector2.ONE)
		draw_string(font, Vector2.ZERO, text)
