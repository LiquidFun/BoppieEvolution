extends TextureRect

var height = 80
var width = 300
var scale_height = 2
var curr_index = 0
var plot = Image.new()
var owlie_pixel_indeces = []
var kloppie_pixel_indeces = []
var reset_color = Color(1, 1, 1, .1)

func _ready():
	plot.create(width, height, false, Image.FORMAT_RGBA8)
	plot.fill(reset_color)
	self.texture = ImageTexture.new()
	rect_size = Vector2(width, height * scale_height)
	rect_min_size = Vector2(width, height * scale_height)
	update()
	for _i in range(width):
		owlie_pixel_indeces.append(0)
		kloppie_pixel_indeces.append(0)
	self.rect_scale.y = scale_height
	
	$Timer.connect("timeout", self, "_on_HalfSecondTimer")
	#Globals.connect("HalfSecondTimer", self, "_on_HalfSecondTimer")
	
func _on_HalfSecondTimer():
	draw_next_pixel()

func draw_next_pixel():
	var owlies = clamp(get_tree().get_nodes_in_group("Owlie").size(), 1, height)
	var kloppies = clamp(get_tree().get_nodes_in_group("Kloppie").size(), 1, height)
	var some_pixels_ahead = (curr_index + 30) % width
	var next_index = (curr_index + 1) % width
	plot.lock()
	for i in range(10):
		plot.set_pixel(next_index, i, Color.white)
		plot.set_pixel(curr_index, i, reset_color)
	plot.set_pixel(some_pixels_ahead, owlie_pixel_indeces[some_pixels_ahead], reset_color)
	plot.set_pixel(some_pixels_ahead, kloppie_pixel_indeces[some_pixels_ahead], reset_color)
	plot.set_pixel(curr_index, height - owlies, Color.green)
	plot.set_pixel(curr_index, height - kloppies, Color.cyan)
	plot.unlock()
	texture.create_from_image(plot)
	owlie_pixel_indeces[curr_index] = height - owlies
	kloppie_pixel_indeces[curr_index] = height - kloppies
	curr_index = next_index

