extends RayCast2D


func _draw():
	if Globals.draw_vision_rays:
		draw_line(Vector2.ZERO, self.cast_to, Color.white, 1)

func _physics_process(delta):
	if Globals.draw_vision_rays:
		if is_colliding():
			var collider = get_collider()
			if collider is Boppie:
				self.modulate = Color.green
			elif collider is Food:
				self.modulate = Color.red
		else:
			self.modulate = Color.white
		
