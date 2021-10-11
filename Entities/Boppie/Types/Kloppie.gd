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
	eats = Raytype.KLOPPIE if Globals.kloppies_cannibals else Raytype.OWLIE
	max_boost_factor = 3.0
	max_energy = 40
	ray_length = 500
	required_offspring_energy = 20
	size_increases = [.9, 1.2, 1.5]
	type = "Kloppie"
	
	
func _ready():
	if Globals.kloppies_cannibals:
		$EatingArea.collision_mask |= (1 << 3)
		for vision_ray in vision_rays:
			vision_ray.collision_mask |= (1 << 3)

func _on_EatingArea_body_entered(body):
	if can_attack and not dead:
		if body is Owlie or (body.type == "Kloppie" and eats == Raytype.KLOPPIE and body != self):
			if body.take_damage(damage * self.scale.x * self.scale.x * max(.1, movement)):
				eat(body)
			else:
				yield(get_tree().create_timer(.5), "timeout")
				if is_instance_valid(body) and $EatingArea.overlaps_body(body):
					_on_EatingArea_body_entered(body)
