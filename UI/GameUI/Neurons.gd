extends PanelContainer

var neural_network = null setget set_neural_network
var height := 250.0
var width := 400.0
var neuron_radius := 15
var margins = neuron_radius * 2
var neuron_dist = neuron_radius * 3
var font = get_font("font") 
var neuron_weight_gradient: Gradient = load("res://UI/GameUI/NeuronWeight.tres")
var depth_map = {}
var layers = []

func calculate_depth_map():
	depth_map = {}
	for connection in neural_network.connections_internal:
		depth_map[connection[0]] = 1
		for i in range(0, len(connection[1]), 2):
			depth_map[connection[0]] = max(depth_map[connection[1][i]]+1, depth_map[connection[0]])
	layers = []
	for key in depth_map:
		if layers.size() < depth_map[key]:
			layers.append([])
		layers[depth_map[key]-1].append(key)

func _ready():
	self.rect_min_size = Vector2(width, height)

func set_neural_network(nn):
	neural_network = nn
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
			var color = neuron_weight_gradient.interpolate((dendron + 1) / 2.0)
			draw_line(left_pos, right_pos, color, abs(dendron * 3))

	# Draw neurons
	for index in lookup_index_to_pos:
		var pos = lookup_index_to_pos[index]
		var text_pos = pos + Vector2(-neuron_radius * .7, neuron_radius * .4)
		var value = clamp((values[index] + 1) / 3.0, 0, 1)
		draw_circle(pos, neuron_radius, Color.darkolivegreen.lightened(value))
		draw_string(font, text_pos, "%.1f" % values[index], Color.black)
