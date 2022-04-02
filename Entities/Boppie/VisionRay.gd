extends RayCast2D

export(Color) var default_color = Color(1, 1, 1, 0.8)
export var draw_when_all = true

func _draw():
	draw_line(Vector2.ZERO, self.cast_to, default_color, 1)
		
func collision_distance():
	if is_colliding():
		return global_transform.origin.distance_to(get_collision_point()) / self.cast_to.length()
	return 2
	
func collision_type():
	if is_colliding():
		var collider = get_collider()
		if collider is Owlie:
			return Data.Raytype.OWLIE
		elif collider is Kloppie:
			return Data.Raytype.KLOPPIE
		elif collider is Food:
			return Data.Raytype.FOOD
	return Data.Raytype.NONE

func _physics_process(_delta):
	if Globals.draw_senses and draw_when_all or get_parent().draw_senses:
		self.visible = true
		if is_colliding():
			var collider = get_collider()
			if collider is Food:
				self.modulate = Color.green
			elif collider is Area2D:
				self.modulate = Color.blue
			else:
				self.modulate = Color.red
		else:
			self.modulate = Color.white
	else:
		self.visible = false
