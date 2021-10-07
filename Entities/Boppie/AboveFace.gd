extends Node2D

onready var face = get_parent()

func get_points(pos, add):
	var r = face.eye_radius
	var base = pos + Vector2(r * 1.1, 0)
	return [
		base + Vector2(0, r * .4), 
		base - Vector2(0, r * .4), 
		base - Vector2(r * .5, r) + add, 
		base - Vector2(r * .5, -r) - add
	]
	

func _draw():
	var add = Vector2(face.eye_radius * .15, 0)
	draw_colored_polygon(get_points(face.pos, -add), Color.white)
	draw_colored_polygon(get_points(face.pos_other, add), Color.white)

