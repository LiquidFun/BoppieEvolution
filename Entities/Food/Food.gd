extends Area2D

class_name Food

export var nutrition = 5
var eaten = false

var color = Color(1, 0, 0)

func _init():
	Globals.current_food_count += 1


func _draw():
	draw_circle(Vector2.ZERO, 10, color)


func _on_Food_body_entered(body):
	if body is Boppie and not body.dead and not eaten:
		eaten = true
		body.eat(self)
		color = Color(0, 0, 0, 0)
		self.update()
		if not Globals.performance_mode:
			$FoodEaten.emitting = true
		
		yield(get_tree().create_timer(1.0), "timeout")
		
		Globals.current_food_count -= 1
		queue_free()
