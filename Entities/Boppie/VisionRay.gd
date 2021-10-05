extends RayCast2D


func _draw():
	draw_line(Vector2.ZERO, self.cast_to, Color.white, 1)
		
func collision_distance():
	if is_colliding():
		return global_transform.origin.distance_to(get_collision_point()) / self.cast_to.length()
	return 1
	
func collision_type():
	if is_colliding():
		var collider = get_collider()
		if collider is Boppie:
			return Boppie.Raytype.BOPPIE
		elif collider is Food:
			return Boppie.Raytype.FOOD
	return Boppie.Raytype.NONE

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
	else:
		self.modulate = Color(1, 1, 1, 0)
