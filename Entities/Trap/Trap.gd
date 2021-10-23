extends Area2D

func _draw():
	draw_circle(Vector2.ZERO, 20, Color.darkslategray)



func _on_Trap_body_entered(body):
	if body is Boppie:
		body.take_damage(15)
