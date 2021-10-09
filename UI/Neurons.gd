extends PanelContainer

var neural_network = null setget set_neural_network
var height := 250.0
var width := 300.0
var neuron_radius := 15
var margins = neuron_radius * 2
var neuron_dist = neuron_radius * 3
var font = get_font("font") 
var neuron_weight_gradient: Gradient = load("res://UI/NeuronWeight.tres")

func _ready():
	self.rect_min_size = Vector2(width, height)

func set_neural_network(nn):
	neural_network = nn
	for layer in neural_network.values:
		self.height = max(height, (layer.size() - 1) * neuron_dist + margins * 2)
		rect_min_size = Vector2(width, height)
	self.update()

func _draw():
	if neural_network == null:
		return
	var values = neural_network.values
	var weights = neural_network.weights
	var inside_height = height - margins * 2
	var inside_width = width - margins * 2
	var layer_count = values.size()
	var xs = []
	var start_ys = []
	
	# Calculate offsets
	for layer in range(layer_count):
		xs.append(margins + layer * inside_width / (layer_count - 1))
		start_ys.append(margins + (inside_height / 2) - ((values[layer].size() - 1) * neuron_dist) / 2)
		
	# Draw neurons
	for layer in range(layer_count - 1):
		for neuron in range(values[layer].size()):
			var y = start_ys[layer] + neuron * neuron_dist
			for right in range(weights[layer].size()):
				var weight = weights[layer][right][neuron] 
				var dendron = weight * values[layer][neuron]
				var y_right = start_ys[layer + 1] + right * neuron_dist
				var color = neuron_weight_gradient.interpolate((dendron + 1) / 2.0)
				draw_line(Vector2(xs[layer], y), Vector2(xs[layer + 1], y_right), color, abs(dendron * 3))
		
	# Draw neurons
	for layer in range(layer_count):
		for neuron in range(values[layer].size()):
			var y = start_ys[layer] + neuron * neuron_dist
			var pos = Vector2(xs[layer], y)
			var text_pos = pos + Vector2(-neuron_radius * .7, neuron_radius * .4)
			var value = clamp((values[layer][neuron] + 1) / 3.0, 0, 1)
			draw_circle(pos, neuron_radius, Color.darkolivegreen.lightened(value))
			draw_string(font, text_pos, "%.1f" % values[layer][neuron], Color.black)
