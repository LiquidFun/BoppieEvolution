extends Node2D

var dead = false

func die():
	dead = true
	self.update()


func _draw():
	var pupil_radius = get_parent().eye_radius * .6
	if dead:
		var coord1 = Vector2(-pupil_radius, pupil_radius)
		var coord2 = Vector2(pupil_radius, pupil_radius)
		draw_line(coord1, -coord1, Color.black, pupil_radius * .3, true)
		draw_line(coord2, -coord2, Color.black, pupil_radius * .3, true)
	else:
		draw_circle(get_parent().pupil_offset, pupil_radius, Color.black)
		var reflection_pos = get_parent().pupil_offset + Vector2(pupil_radius, pupil_radius) * .3
		draw_circle(reflection_pos, pupil_radius * .3, Color.white)
		#draw_circle(reflection_pos - Vector2(pupil_radius * .4, -pupil_radius * .2), pupil_radius * .1, Color.white)
