extends PanelContainer

var neural_network = null setget set_neural_network
var height := 250.0
var width := 400.0
var neuron_radius := 14
var margins = neuron_radius * 3
var neuron_dist = neuron_radius * 2.2
var font = get_font("font") 
var neuron_weight_gradient: Gradient = load("res://UI/GameUI/NeuronWeight.tres")
var neuron_activation_gradient: Gradient = load("res://UI/GameUI/NeuronActivation.tres")
var neuron_importance_gradient: Gradient = load("res://UI/GameUI/NeuronImportance.tres")
var depth_map = {}
var layers = []
var lookup_index_to_pos = {}
var focused_neuron_index = -1
var default_connection_color = Color("1dffffff")
var dragging_neuron = false

enum DisplayProfile { ACTIVATIONS, WEIGHTS, IMPORTANCE } # , IMPORTANCE
var profile = DisplayProfile.ACTIVATIONS

# Colors
var default_neuron_color = Color.darkolivegreen
var neuron_colors = {
	"HiddenNeuron": Color.dimgray,
	"VisionRayEats": Color.darkgoldenrod,
	"DangerSense": Color.darkred,
	"FriendlySense": Color.darkgreen,
	"Thrst": Color.darkblue,
	"Watr": Color.darkcyan,
	"Bias": Color.white,
	"Hnger": Color.darkgreen,
	"Tmer": Color.midnightblue,
	"Timer": Color.midnightblue,
	"Hunger": Color.coral,
	"Water": Color.darkcyan,
	"Grnd": Color("4f2907"),
	"Ground": Color("4f2907"),
	"Move": Color.maroon,
	"Turn": Color.darkcyan,
}


func get_neuron_color(index, value):
	var name = Data.generalize_neuron_name(neural_network.neuron_index_to_name[index])
	var color = neuron_colors.get(name, default_neuron_color)
	return color.lightened(clamp(value, -0.8, 0.8))

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
		for i in range(0, len(connection[1]), 3):
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
	for display_profile in DisplayProfile.keys():
		$HBoxContainer/DisplayProfile.add_item(str(display_profile).capitalize())
		
func _on_OptionButton_item_selected(index: int) -> void:
	profile = DisplayProfile.values()[index]

func set_neural_network(nn):
	neural_network = nn
	lookup_index_to_pos = {}
	if neural_network != null:
		calculate_depth_map()
		for layer in layers:
			self.height = max(height, (layer.size() - 1) * neuron_dist + margins * 2)
			rect_min_size = Vector2(width, height)
		self.update()
	
func _process(_delta):
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
	var neuron_dists = []
	var neuron_importance_sums = {-1: 1}
	
	# Calculate offsets
	for layer in range(layers.size()):
		xs.append(margins + layer * inside_width / (layers.size() - 1))
		neuron_dists.append(neuron_dist + max(0, 10 - len(layers[layer])) * 10)
		start_ys.append(margins + (inside_height / 2) - ((layers[layer].size() - 1) * neuron_dists[-1]) / 2)
		
	# Neuron index to position lookup
	if not lookup_index_to_pos:
		for layer in range(layers.size()):
			for neuron in range(layers[layer].size()):
				var y = start_ys[layer] + neuron * neuron_dists[layer]
				lookup_index_to_pos[layers[layer][neuron]] = Vector2(xs[layer], y)
		
	# Draw connections between neurons
	for connection in connections:
		var right_pos = lookup_index_to_pos[connection[0]]
		for i in range(0, len(connection[1]), 3):
			var left_pos = lookup_index_to_pos[connection[1][i]]
			var weight = connection[1][i+1]
			var dendron = weight * values[connection[1][i]]
			var thickness = 0.2
			var color = default_connection_color
			if focused_neuron_index == connection[0] or focused_neuron_index == -1:
				match profile:
					DisplayProfile.ACTIVATIONS: 
						thickness = dendron
						color = neuron_activation_gradient.interpolate((thickness + 1) / 2.0)
					DisplayProfile.WEIGHTS: 
						thickness = weight
						color = neuron_weight_gradient.interpolate((thickness + 1) / 2.0)
					DisplayProfile.IMPORTANCE: 
						thickness = connection[1][i+2]
						neuron_importance_sums[connection[1][i]] = thickness + neuron_importance_sums.get(connection[1][i], 0)
						color = neuron_importance_gradient.interpolate(thickness)
				if focused_neuron_index != -1:
					# var mid_pos = left_pos * 0.85 + right_pos * 0.15
					var mid_pos = left_pos + Vector2(neuron_radius * 1.5, 3)
					var color_opaque = Color(color.r, color.g, color.b, 1)
					draw_string(font, mid_pos, str(round(thickness * 100) / 100.0), color_opaque)
			draw_line(left_pos, right_pos, color, abs(thickness * 3))
			

	
	# Draw neurons
	for index in lookup_index_to_pos:
		var pos = lookup_index_to_pos[index]
		var text_pos = pos + Vector2(-neuron_radius * .7, neuron_radius * .4)
		var color = get_neuron_color(index, values[index])
		if focused_neuron_index == index and focused_neuron_index != -1:
			draw_circle(pos, neuron_radius*1.1, Color.white)
		var curr_neuron_radius = neuron_radius
		match profile:
			DisplayProfile.IMPORTANCE:
				var max_neuron_importance = neuron_importance_sums.values().max()
				curr_neuron_radius = neuron_radius * neuron_importance_sums.get(index, 0) / max_neuron_importance
		draw_circle(pos, curr_neuron_radius, color)
		draw_string(font, text_pos, "%.1f" % values[index], Color.black)
		
	# Calculate positions of help-banners explaining neuron meaning
	var input_neurons = neural_network.neuron_index_to_name
	var neuron_group_ranges = Dictionary()
	for layer_index in [0, -1]:
		var first_index = 0
		var layer = layers[layer_index]
		for index in range(0, len(layer)):
			var text = Data.generalize_neuron_name(input_neurons[layer[index]])
			var comparison_text = Data.generalize_neuron_name(input_neurons[layer[first_index]])
			# var similarity = input_neurons[layer[index]].similarity(input_neurons[layer[first_index]])
			if text != comparison_text:
				first_index = index
			var upper_pos = lookup_index_to_pos[layer[index]]
			var lower_pos = lookup_index_to_pos[layer[first_index]]
			var start_or_end_factor = -1 if layer_index == 0 else 1
			var add_x = (neuron_radius + 5) * start_or_end_factor
			upper_pos += Vector2(add_x, neuron_radius)
			lower_pos += Vector2(add_x, -neuron_radius)
			neuron_group_ranges[text] = [upper_pos, lower_pos, start_or_end_factor]

	# Draw lines for the help banners
	for text in neuron_group_ranges:
		var upper_lower_pos = neuron_group_ranges[text]
		draw_line(upper_lower_pos[0], upper_lower_pos[1], Color(1, 1, 1), 1, true)
		var divets =  Vector2(-8, 0) * upper_lower_pos[2]
		draw_line(upper_lower_pos[0], upper_lower_pos[0] + divets, Color(1, 1, 1), 1, true)
		draw_line(upper_lower_pos[1], upper_lower_pos[1] + divets, Color(1, 1, 1), 1, true)
		
	# Draw text for the help banners
	for text in neuron_group_ranges:
		var upper_lower_pos = neuron_group_ranges[text]
		var text_pos = (upper_lower_pos[0] + upper_lower_pos[1]) / 2
		text_pos -= Vector2(-3, 7 * len(text) / 2) * upper_lower_pos[2]
		draw_set_transform(text_pos, upper_lower_pos[2] * PI/2, Vector2.ONE)
		draw_string(font, Vector2.ZERO, text)

func _input(event):
	if event is InputEventMouseMotion and neural_network:
		var mouse = get_local_mouse_position()
		if not dragging_neuron:
			focused_neuron_index = -1
			for conn in neural_network.connections_internal:
				if conn[0] in lookup_index_to_pos:
					if mouse.distance_to(lookup_index_to_pos[conn[0]]) < neuron_radius * 1.2:
						focused_neuron_index = conn[0]
		if focused_neuron_index != -1 and dragging_neuron:
			lookup_index_to_pos[focused_neuron_index] = mouse
	if event is InputEventMouseButton and neural_network:
		if dragging_neuron and event.button_mask == 0:
			dragging_neuron = false
		elif focused_neuron_index != -1:
			dragging_neuron = true
		
