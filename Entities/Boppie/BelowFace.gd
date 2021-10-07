extends Node2D

onready var face = get_parent()

func _draw():
	var factor = 1.2
	draw_circle(face.pos, face.eye_radius * factor, Color.white)
	draw_circle(face.pos_other, face.eye_radius * factor, Color.white)
