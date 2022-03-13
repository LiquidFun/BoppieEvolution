extends Area2D

class_name Food

var nutrition
var draw_icon
var draw_color
var eaten = false

# Normal people would just use a texture... but noo, it has to be this way
var font = Globals.icon_font
export(Data.FoodType) var food_type = Data.FoodType.PLANT


signal FoodEaten(Food)

var color = Color(1, 0, 0)

func _init():
	scale = Vector2.ZERO
	
func _ready():
	Globals.add_food(food_type)
	var deteriorate_time = -1
	var scale_anim_time = 2.5
	match food_type:
		Data.FoodType.PLANT:
			nutrition = 5
			draw_icon = "" # Plant icon
			draw_color = Color.green
		Data.FoodType.MEAT:
			nutrition = 10
			draw_icon = "" # Bacon icon
			draw_color = Color.darkred
			scale_anim_time = 0.5
			deteriorate_time = 60
			
	$Tween.interpolate_property(
		self, "scale", Vector2.ONE * .01, Vector2.ONE * .5, 
		scale_anim_time, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT
	)
	$Tween.start()
	if deteriorate_time > 0:
		$Tween.interpolate_property(
			self, "scale", Vector2.ONE * .5, Vector2.ZERO, 
			deteriorate_time, Tween.EASE_IN_OUT, Tween.EASE_IN_OUT
		)
		$Tween.start()
		$Timer.wait_time = deteriorate_time
		$Timer.start()


func _draw():
	var size = font.size / 2
	match food_type:
		Data.FoodType.PLANT:
			draw_circle(Vector2(0, 0.85 * size), 7, Color(0, 0, 0, .2))
			draw_string(font, Vector2(-1, .75) * size, draw_icon, draw_color.lightened(.8))
			draw_string(font, Vector2(-1, .9) * size, draw_icon, draw_color.darkened(.4))
		Data.FoodType.MEAT:
			draw_string(font, Vector2(-1.05, .75) * size, draw_icon, draw_color.lightened(.4))
	draw_string(font, Vector2(-1, .8) * size, draw_icon, draw_color)
	
func reset():
	eaten = false
	self_modulate.a = 1

func _on_Food_body_entered(body):
	if body.eats == Data.Raytype.FOOD and not body.dead and not eaten:
		eaten = true
		self_modulate.a = 0
		if not Globals.performance_mode:
			$FoodEatenParticles.emitting = true
		body.eat(self)
		
		yield(get_tree().create_timer(1.0), "timeout")
		
		Globals.add_food(food_type, -1)
		queue_free()
		# emit_signal("FoodEaten", self)


func _on_Timer_timeout() -> void:
	if is_instance_valid(self) and not eaten:
		Globals.add_food(food_type, -1)
		queue_free()
