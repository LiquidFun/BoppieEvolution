extends Area2D
onready var parent = get_parent()
onready var radius = parent.danger_sense_radius
onready var parts = parent.danger_sense_parts

export var inherit_parent_collision_mask = -1
export var color = Color.red
export var sense = Data.Sense.DANGER_SENSE

func _ready() -> void:
	$CollisionShape2D.shape.radius = radius
	_on_Boppie_DrawSenses(false)
	if inherit_parent_collision_mask != -1:
		collision_mask = inherit_parent_collision_mask & parent.collision_layer
	
func _process(delta: float) -> void:
	if parent.draw_senses:
		update()
		
func get_activations():
	var activations = []
	for i in range(parts):
		activations.append(0)
	for body in get_overlapping_bodies() + get_overlapping_areas():
		if body == parent:
			continue
		var vec_to = body.position - parent.position
		var angle = parent.rotation_vector().angle_to(vec_to) + PI*2
		var index = int((angle / (PI*2)) * parts + 0.5) % parts
		var radius = $CollisionShape2D.shape.radius
		var value = 1.0 - (vec_to.length() / (radius * parent.scale.x)) / 2.0
		activations[index] = max(activations[index], value)
	return activations

	
func _draw():
	var nn_index = parent.nn_input_array_senses_start_indeces[sense]
	var angle = PI * 2 / parts
	for i in range(parts):
		var start_angle = angle / 2 + i * angle - PI / 2
		var end_angle = start_angle + angle
		var points = [Vector2.ZERO]
		while start_angle <= end_angle:
			points.push_back(Vector2(cos(start_angle) * radius, sin(start_angle) * radius))
			start_angle += PI / 20
		points.push_back(Vector2.ZERO)
		# draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 10, Color.white, 2, false)
		var modifed_color = Color(color.r, color.g, color.b, parent.nn_input_array[nn_index+i] / 10)
		draw_colored_polygon(points, modifed_color)


func _on_Boppie_DrawSenses(new_value) -> void:
	visible = new_value
	set_process(new_value)
