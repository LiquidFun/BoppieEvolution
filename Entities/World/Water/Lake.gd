tool
extends Area2D


export var redraw = true
export var height = 100
export var radius = 500
export var resistance = 0.7
var points = []
var water_color = Color.deepskyblue

func _ready() -> void:
	$CollisionShape2D.shape.height = height
	$CollisionShape2D.shape.radius = radius
	
func _process(delta: float) -> void:
	if redraw:
		$CollisionShape2D.shape.height = height
		$CollisionShape2D.shape.radius = radius
		update()
		redraw = false
		
func draw_lake_poly(color, factor=1.0, line_thickness=null):
	var new_points = points.duplicate()
	for i in range(len(new_points)):
		new_points[i] *= factor
	if line_thickness != null:
		draw_polyline(new_points, color, line_thickness)
	else:
		draw_colored_polygon(new_points, color)
	
func _draw():
	var add_x = 0
	var add_y = 0
	var eccentricity = radius / 50
	points = []
	var points_count = 200
	for i in range(points_count):
		var angle = i * PI * 2 / points_count
		add_x += (randf() - 0.5) * eccentricity
		add_y += (randf() - 0.5) * eccentricity
		if angle > PI*2 * 0.75:
			add_x *= .97
			add_y *= .97
		var x = cos(angle) * radius + add_x
		var y = sin(angle) * radius + add_y + height / 2 * (1 if angle < PI else -1)
		points.append(Vector2(x, y))
	points.append(points[0])
	draw_lake_poly(Color.darkslategray, 1.01)
	draw_lake_poly(water_color)
	for i in range(3):
		draw_lake_poly(Color(1, 1, 1, .8), 0.98 - i * 0.02, 3 - i * 0.3)
	for i in range(4):
		draw_lake_poly(water_color.darkened(0.1 * i), 0.8 - i * 0.1)
		

func _on_Lake_body_entered(body: Node) -> void:
	if body is Boppie:
		body.ground_movement_penalty_factor = 1 - resistance
		body.update_water(100)


func _on_Lake_body_exited(body: Node) -> void:
	if body is Boppie:
		body.ground_movement_penalty_factor = 1
