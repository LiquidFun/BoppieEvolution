extends Control

class_name TimePlot

class Dataset:
	var name
	var color
	var max_points
	var x_counter = 0
	var points = []
	var plot_stderr
	var stderr_points_above = []
	var stderr_points_below = []
	
	func _init(name, color = Color.white, max_points = 1000, plot_stderr=false):
		self.name = name
		self.color = color
		self.max_points = max_points
		self.plot_stderr = plot_stderr

	func add_point(y, stderr=0):
		self.points.push_back(Vector2(x_counter, y))
		if plot_stderr:
			self.stderr_points_above.push_back(Vector2(x_counter, y+stderr))
			self.stderr_points_below.push_back(Vector2(x_counter, y-stderr))
		x_counter += 1
		if len(points) > max_points:
			points.pop_front()
			if plot_stderr:
				stderr_points_below.pop_front()
				stderr_points_above.pop_front()
		
enum PlotType { LINES }

var y_scale = 1
var datasets = {}
var plot_type = PlotType.LINES
var background_color = Color(1, 1, 1, 0.1)
var font = get_font("font") 
var draw_legend = true
var line_thickness = 2

func add_dataset(name, color, plot_stderr=false):
	datasets[name] = Dataset.new(name, color, rect_size.x, plot_stderr)

func add_point(dataset_name, y, stderr=0):
	datasets[dataset_name].add_point(y)
	
func _draw():
	var size = rect_size
	draw_rect(Rect2(0, 0, size.x, size.y), background_color)
	match plot_type:
		PlotType.LINES:
			for name in datasets:
				var dataset = datasets[name]
				if len(dataset.points) >= 2:
					draw_set_transform(
						Vector2(size.x - dataset.points[0].x - len(dataset.points), size.y), 
						0, 
						Vector2(1, -y_scale)
					)
					draw_polyline(dataset.points, dataset.color, line_thickness)
					if dataset.plot_stderr:
						for points in [dataset.stderr_points_above, dataset.stderr_points_below]:
							draw_polyline(points, dataset.color.darkened(0.1), line_thickness / 2.0)	
					draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
					
	if draw_legend:
		var offset = 3
		var curr_y = offset
		var box_size = 9
		for name in datasets:
			var dataset = datasets[name]
			draw_rect(Rect2(offset, curr_y, box_size, box_size), dataset.color)
			draw_string(font, Vector2(offset * 2 + box_size, curr_y+box_size), name)
			curr_y += box_size + offset
			
		
