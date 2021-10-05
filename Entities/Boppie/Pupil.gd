extends Node2D


func _draw():
	var pupil_radius = get_parent().eye_radius * .6
	draw_circle(Vector2.ZERO, pupil_radius, Color.black)
