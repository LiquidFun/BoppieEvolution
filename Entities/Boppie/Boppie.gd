extends KinematicBody2D

export var radius = 20
export var move_speed = 10000
export var turn_speed = 2
var selected = false setget set_selected
var hovered = false setget set_hovered

signal BoppieClicked

func draw_corner(corner: Vector2, add: Vector2):
	var offset = 3
	var color = Color(1, 0, 0)
	var from = corner + add * offset
	var length = (radius + offset * 2) / 3
	draw_line(from, from - Vector2(add.x, 0) * length, color, 1, true)
	draw_line(from, from - Vector2(0, add.y) * length, color, 1, true)
	
func draw_selection():
	for x in [-1, 1]:
		for y in [-1, 1]:
			var corner = Vector2(x, y) * radius
			draw_corner(corner, Vector2(x, y))

func _draw():
	if selected:
		draw_selection()
	var boppie_color = self.modulate
	if hovered:
		boppie_color = boppie_color.darkened(.3)
	draw_circle(Vector2.ZERO, radius, boppie_color)
	
	draw_circle(Vector2.ZERO, 3, Color(1, 0, 0))
	draw_line(Vector2.ZERO, Vector2(radius, 0), Color(0, 0, 0))
	
	
func set_selected(select):
	selected = select
	self.update()
	
func set_hovered(hover):
	hovered = hover
	self.update()
	
func rotation_vector():
	return Vector2(cos(self.rotation), sin(self.rotation))

func move(factor, delta):
	var rot = rotation_vector()
	self.move_and_slide(rot * factor * move_speed * delta, Vector2.UP)
	
	
func turn(factor, delta):
	self.rotation += factor * turn_speed * delta


func _on_Boppie_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("BoppieClicked", self)


func _on_Boppie_mouse_entered():
	set_hovered(true)


func _on_Boppie_mouse_exited():
	set_hovered(false)
