extends Area2D
onready var parent = get_parent()
onready var radius = parent.danger_sense_radius
onready var parts = parent.danger_sense_parts

func _ready() -> void:
	$CollisionShape2D.shape.radius = radius
	_on_Boppie_DrawSenses(false)
	
func _process(delta: float) -> void:
	if parent.draw_senses:
		update()

	
func _draw():
	var nn_index = parent.nn_input_array_senses_start_indeces[Data.Senses.DANGER_SENSE]
	var angle = PI * 2 / parts
	for i in range(parts):
		var start_angle = PI / 2 + angle / 2 + i * angle
		var end_angle = start_angle + angle
		var points = [Vector2.ZERO]
		while start_angle <= end_angle:
			points.push_back(Vector2(cos(start_angle) * radius, sin(start_angle) * radius))
			start_angle += PI / 20
		points.push_back(Vector2.ZERO)
		# draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 10, Color.white, 2, false)
		var color = Color(1, 0, 0, parent.nn_input_array[nn_index+i] / 10)
		draw_colored_polygon(points, color)


func _on_Boppie_DrawSenses(new_value) -> void:
	visible = new_value
	set_process(new_value)
