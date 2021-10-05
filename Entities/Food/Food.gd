extends Area2D


export var nutrition = 5
var food_eaten_particles = preload("res://Particles/FoodEaten.tscn")

var color = Color(1, 0, 0)

func _init():
	Globals.current_food_count += 1
	


func _draw():
	draw_circle(Vector2.ZERO, 10, color)


func _on_Food_body_entered(body):
	if body is Boppie:
		body.eat(self)
		var particles = food_eaten_particles.instance()
		add_child(particles)
		particles.position = Vector2.ZERO
		color = Color(0, 0, 0, 0)
		self.update()
		particles.emitting = true
		
		yield(get_tree().create_timer(1.0), "timeout")
		
		Globals.current_food_count -= 1
		queue_free()
