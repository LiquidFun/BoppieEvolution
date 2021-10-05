extends Node2D

export(Vector2) onready var radius = get_parent().radius
export(Vector2) onready var pos = Vector2(radius * .5, radius * .3 + 1.5)
export(Vector2) onready var pos_other = pos * Vector2(1, -1)
export(Vector2) onready var eye_radius = radius * .3
export(Vector2) onready var pupil_offset = Vector2(radius * .1, 0)

func _draw():
	draw_circle(pos, eye_radius, Color.white)
	draw_circle(pos_other, eye_radius, Color.white)
	
func _ready():
	$Pupil1.position = pos
	$Pupil2.position = pos_other
	
func eyes_dead():
	$Pupil1.die()
	$Pupil2.die()

func rotate_pupils(rotation):
	$Pupil1.rotation = rotation * .8
	$Pupil2.rotation = rotation * .8

func scale_pupils(factor):
	factor = clamp(factor, 1, 1.3)
	factor = Vector2(factor, factor)
	$Pupil1.scale = factor
	$Pupil2.scale = factor
