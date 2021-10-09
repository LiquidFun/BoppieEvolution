extends Boppie

class_name Kloppie

var damage = 7
var attack_delay = .8
var can_attack = true

func _init():
	energy_gradient = "res://Entities/Boppie/Types/KloppieEnergyGradient.tres"
	draw_teeth = true
	draw_body_type = Boppie.BodyType.HEXAGONAL
	draw_hair = false
	draw_nose = true
	draw_eyes = true
	draw_eyebrows = true
	eats = Raytype.OWLIE
	max_boost_factor = 3.0
	max_energy = 30
	required_offspring_energy = 30
	size_increases = [1, 1.2, 1.4]
	type = "Kloppie"

func _on_EatingArea_body_entered(body):
	if can_attack and body is Owlie:
		if body.take_damage(damage * self.scale.x * max(.5, movement)):
			eat(body)
