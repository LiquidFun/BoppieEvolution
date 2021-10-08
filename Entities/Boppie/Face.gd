extends Node2D

onready var parent = get_parent()
onready var radius = parent.radius
onready var pos = Vector2(radius * .5, radius * .3 + 1.5)
onready var pos_other = pos * Vector2(1, -1)
onready var eye_radius = radius * .3
onready var pupil_offset = Vector2(radius * .1, 0)

onready var tween = parent.get_node("Tween")

func _draw():
	if parent.draw_eyes:
		draw_eyes()
	if parent.draw_nose:
		draw_nose()
	if parent.draw_teeth:
		draw_teeth()
	
func draw_nose():
	var nose_color = Color(.7, 0, 0)
	var nose_shadow_color = Color(.4, 0, 0, .4)
	draw_colored_polygon([Vector2(4, 0), Vector2(0, 3), Vector2(0, -3)], nose_color)
	draw_colored_polygon([Vector2(-1, -3), Vector2(-1, 3), Vector2(0, 3), Vector2(0, -3)], nose_shadow_color)
	
func draw_eyes():
	draw_circle(pos, eye_radius, Color.white)
	draw_circle(pos_other, eye_radius, Color.white)
	
func _draw_tooth(start: Vector2, spacing: float):
	var end = start + Vector2(0, spacing)
	var peek = (start + end) / 2 - Vector2(abs(spacing), 0) * 2
	draw_colored_polygon([start * 1.1, peek * 1.1, end * 1.1], Color(0, 0, 0, .4))
	draw_colored_polygon([start, peek, end], Color.white)
	
func draw_teeth():
	#var center = Vector2(cos(deg2rad(30)) * radius, 0)
	var center = Vector2(-radius * .25, 0)
	var spacing = radius / 9
	var teeth = 6
	for i in range(teeth / 2):
		var factor = 1.5 if i == (teeth / 2 - 1) else 1
		_draw_tooth(center + Vector2(0, spacing) * i, spacing * factor)
		_draw_tooth(center - Vector2(0, spacing) * i, -spacing * factor)
	
func _ready():
	$Pupil1.position = pos
	$Pupil2.position = pos_other
	
func eyes_dead():
	$Pupil1.die()
	$Pupil2.die()

func rotate_pupils(rotation):
	if not Globals.performance_mode:
		for pupil in [$Pupil1, $Pupil2]:
			tween.interpolate_property(
				pupil, "rotation", pupil.rotation, rotation * .8, 
				.05, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT
			)
			tween.start()
		
func scale_eyes(factor):
	if not Globals.performance_mode:
		factor = clamp(factor, 1, 1.1)
		factor = Vector2(factor, factor)
		tween.interpolate_property(
			self, "scale", scale, factor, 
			.05, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT
		)
		tween.start()

func scale_pupils(factor):
	if not Globals.performance_mode:
		factor = clamp(factor, 1, 1.3)
		factor = Vector2(factor, factor)
		for pupil in [$Pupil1, $Pupil2]:
			tween.interpolate_property(
				pupil, "scale", pupil.scale, factor, 
				.1, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT
			)
