extends Area2D

class_name Food

export var nutrition = 5
var eaten = false

signal FoodEaten(Food)

var color = Color(1, 0, 0)

func _init():
	Globals.current_food_count += 1

func _draw():
	draw_circle(Vector2.ZERO, 10, color)
	
func reset():
	eaten = false
	self_modulate.a = 1

func _on_Food_body_entered(body):
	if body.eats == Boppie.Raytype.FOOD and not body.dead and not eaten:
		eaten = true
		self_modulate.a = 0
		if not Globals.performance_mode:
			$FoodEatenParticles.emitting = true
		body.eat(self)
		
		yield(get_tree().create_timer(1.0), "timeout")
		
		Globals.current_food_count -= 1
		queue_free()
		# emit_signal("FoodEaten", self)
