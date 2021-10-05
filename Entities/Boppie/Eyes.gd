extends Node2D

export(Vector2) onready var radius = get_parent().radius
export(Vector2) onready var pos = Vector2(radius * .5, radius * .3 + 1.5)
export(Vector2) onready var pos_other = pos * Vector2(1, -1)
export(Vector2) onready var eye_radius = radius * .3

func _draw():
	draw_circle(pos, eye_radius, Color.white)
	draw_circle(pos_other, eye_radius, Color.white)
	
func _ready():
	$Pupil1.position = pos
	$Pupil2.position = pos_other
