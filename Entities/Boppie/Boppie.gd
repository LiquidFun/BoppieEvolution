extends KinematicBody2D

class_name Boppie

# Properties
var type = "Boppie"
var radius := 20.0  # (too much hardcoded, don't change)
var can_die := true
var nutrition := 20.0
var ground_movement_penalty_factor = 1

# This is reduced down to 0.5 or so, essentially if a boppie does not manage to eat anything
# then it gets a large penalty until it has eaten a few foodstuffs.
var no_food_eaten_penalty = 3.0
var food_type = Data.FoodType.MEAT


# Based on DNA
var max_energy = 15
var max_water = 10
var required_offspring_energy = 10
var ray_count_additional := 2

# DNA
var move_speed := 85.0
var turn_speed := 2.0
var ray_angle := deg2rad(20)
var ray_length := 300.0
var armor := 0.0
var meat_tolerance := 0.0 setget set_meat_tolerance
var danger_sense_radius = 150.0
var max_boost_factor := 2.0
var max_backwards_factor := -0.75
var offspring_mutability := 0.05
var generation = Data.Generation.new()
var scale_factor = 1
var danger_sense_parts = 4
var color = Data.Coloration.new()
var senses = Data.Senses.new(0
	| Data.Sense.VISION_RAY_EATS
	| Data.Sense.DANGER_SENSE
	| Data.Sense.TIMER
	| Data.Sense.HUNGER
	| Data.Sense.THIRST
	| Data.Sense.WATER_RAY
	| Data.Sense.GROUND
	| Data.Sense.BIAS
	| Data.Sense.ALLY_SENSE
)
var timer_neuron = Data.NeuronTimer.new()

var dna_allowed_values = {
	"move_speed": Data.DNABounds.new(70, 100, "x*1/30", 85, 5),  # 3 - 6
	"scale_factor": Data.DNABounds.new(.7, 1.3, "x*x*4"),  # 3 - 9
	"armor": Data.DNABounds.new(0, 5, "x", 0, 0.1),  # 3 - 9
	# "max_energy": Data.DNABounds(10, 30), 
	# "max_water": Data.DNABounds(8, 12), 
	# "required_offspring_energy": Vector2(8, 15), 
	"turn_speed": Data.DNABounds.new(1.7, 3),
	# "ray_count_additional": Vector2(0, 3),
	"meat_tolerance": Data.DNABounds.new(0, 1, "", 0, 0),
	"ray_angle": Data.DNABounds.new(deg2rad(5), deg2rad(50)),
	"ray_length": Data.DNABounds.new(200, 600, "x*1/1000"), # 0.1 - 0.6
	"danger_sense_radius": Data.DNABounds.new(100, 200, "x*1/400"), # 0.25 - 0.5
	"max_boost_factor": Data.DNABounds.new(1.5, 2.5, "x*2"), # 2.5 - 5
	"max_backwards_factor": Data.DNABounds.new(-1.0, -0.5), 
	"offspring_mutability": Data.DNABounds.new(0.03, 0.3, "", 0.05, 0.05),
	"offspring_count": Data.DNABounds.new(1, 5, "", 1, 0),
	"ai.dna": null,
	"generation.i": null,
	"senses.bitmask": null,
	"color.hue": null,
	"timer_neuron.wait_time": Data.DNABounds.new(1, 30),
}

var dna := {} setget set_dna

# var energy_gradient = "res://Entities/Boppie/DefaultEnergyGradient.tres"
var difficulty = Globals.difficulty
var energy_consumption_existing = 1 * difficulty
var energy_consumption_walking = 0.5 * difficulty
var water_consumption_existing = 1 * (difficulty - 0.26)

var vision_rays = []
var draw_senses = false setget set_draw_senses

# AI
var ai = null
var temp_ai = null

var nn_input_array

var selected = false setget set_selected
var hovered = false setget set_hovered

# Drawing
enum BodyType {ROUND, HEXAGONAL}
var draw_body_type =  BodyType.ROUND
var draw_ears = false
var draw_eyebrows = false
var draw_eyes = true
var draw_nose = true
var draw_teeth = false
var draw_hair = false

# Energy and offspring
var size_increases = [0.8, 1, 1.2]
var level = 1
var energy = max_energy * (0.8 + Globals.rng.randf() * 0.2)
var water = max_water
var offspring_energy = 0
var offspring_count = 1
var eats = Data.Raytype.FOOD

var movement := 0.0
var dead = false

# Counters
var offspring_counter = 0
var times_eaten = 0
var times_drank = 0
var spawn_time = 0

signal BoppieClicked(Boppie)
signal BoppieOffspring(Boppie)
signal BoppieDied(Boppie)
signal DrawSenses(new_value)

# ==========================================================================
# Init and draw
# ==========================================================================

func _init(ai=null):
	# color.connect("ColorUpdated", self, "_on_colorUpdated")
	if ai == null:
		ai = NeuralNetwork.new(InnovationManager.common_innovation_ids)
	nn_input_array = ai.values
	self.ai = ai
	add_child(timer_neuron)
	randomize_dna()
	
func _ready():
	initialize_rays()
	initialize_dna()
	spawn_time = Globals.elapsed_time
	# energy_gradient = load(energy_gradient)
	# energy_gradient.set_color(1, Color.from_hsv(color.hue, .5, .5))
	# print(energy_gradient.colors)
	$Tween.interpolate_property(
		self, "scale", Vector2(.2, .2), Vector2(size_increases[0], size_increases[0]) * scale_factor, 
		1, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT
	)
	$Tween.start()
	$SpawnParticles.emitting = true

# ==========================================================================
# DNA
# ==========================================================================

func randomize_dna():
	for property in dna_allowed_values:
		var bounds = dna_allowed_values[property]
		if bounds != null:
			match resolve_subproperty(property):
				[var resolved_subproperty, var last]:
					resolved_subproperty.set(last, bounds.random())

func initialize_dna(random_dna=false):
	dna = {}
	required_offspring_energy = 0
	for property in dna_allowed_values:
		match resolve_subproperty(property):
			[var resolved_subproperty, var last]:
				dna[property] = resolved_subproperty.get(last)
	
				var bounds = dna_allowed_values[property]
				if bounds != null:
					required_offspring_energy += bounds.cost(dna[property])
	max_water = 10 * pow(scale_factor, 2)
	max_energy = 15 * pow(scale_factor, 2)
	
func resolve_subproperty(property):
	var resolved_subproperty = self
	var subproperties = property.split(".")
	var last = subproperties[-1]
	subproperties.remove(subproperties.size() - 1)
	for subproperty in subproperties:
		resolved_subproperty = resolved_subproperty.get(subproperty)
	return [resolved_subproperty, last]

func set_dna(new_dna: Dictionary, mutation_factor=1, crossover_dna=null):
	new_dna = new_dna.duplicate(true)
	for property in new_dna:
		match resolve_subproperty(property):
			[var resolved_subproperty, var last]:
				resolved_subproperty.set(last, new_dna[property])
				if crossover_dna != null and property in crossover_dna:
					resolved_subproperty.crossover(last, crossover_dna[property])
				if mutation_factor > 0:
					resolved_subproperty.mutate(last, new_dna["offspring_mutability"] * mutation_factor)
	initialize_dna()
		
func mutate(property: String, mutability: float):
	var value_range = dna_allowed_values[property]
	var mutation = value_range.upper * mutability * Globals.rng.randfn()
	if dna_allowed_values != null:
		set(property, clamp(get(property) + mutation, value_range.lower, value_range.upper))
		
func crossover(property: String, other_value):
	var remain_current = Globals.rng.randf()
	var take_other = 1 - remain_current
	var value = get(property) * remain_current + other_value * take_other
	set(property, value)
		
	
func set_dna_str(new_dna: String):
	set_dna(str2var(new_dna))
	
func get_dna_str():
	return var2str(dna)
	
func get_fancy_dna_str():
	var fancy := ""
	var bytes := var2str(dna).to_ascii()
	var l := "ACGT"
	for b in bytes:
		fancy += l[(b / 64) % 4] + l[(b / 16) % 4] + l[(b / 4) % 4] + l[b % 4]
	return fancy
	
# ==========================================================================
# Meat tolerance
# ==========================================================================
	
func set_meat_tolerance(tolerance):
	meat_tolerance = tolerance
	var for_carrion = 0.3
	var for_live_meat = 0.7
	var bitmask = 0
	if tolerance < for_carrion:
		bitmask = Globals.PLANT_BIT
	elif for_carrion <= tolerance and tolerance < for_live_meat:
		bitmask = Globals.MEAT_BIT | Globals.PLANT_BIT
		draw_body_type = BodyType.HEXAGONAL
	elif for_live_meat <= tolerance:
		bitmask = Globals.MEAT_BIT
		draw_teeth = true
		draw_body_type = BodyType.HEXAGONAL
		draw_eyebrows = true
		
	collision_mask -= collision_mask & (Globals.PLANT_BIT | Globals.MEAT_BIT)
	collision_mask |= bitmask
	for vision_ray in vision_rays:
		vision_ray.collision_mask |= bitmask
		
	self.update()
		
	
# ==========================================================================
# Rays
# ==========================================================================

func initialize_rays():
	var start_angle = 0
	add_ray(start_angle, true, $VisionRay)
	for i in range(1, ray_count_additional+1):
		add_ray(start_angle + ray_angle * i, true)
		add_ray(start_angle - ray_angle * i, true)
	set_meat_tolerance(meat_tolerance)
	
func add_ray(angle_radians, push_back=true, ray=null):
	if ray == null:
		ray = $VisionRay.duplicate()
		add_child(ray)
	ray.cast_to = Vector2(cos(angle_radians), sin(angle_radians)) * ray_length
	if push_back:
		self.vision_rays.push_back(ray)
	else:
		self.vision_rays.push_front(ray)
	
func set_draw_senses(value):
	draw_senses = value
	emit_signal("DrawSenses", draw_senses)

# ==========================================================================
# AI
# ==========================================================================

func add_temp_ai(ai):
	temp_ai = ai
	
func pop_temp_ai():
	temp_ai = null
	
func calculate_ai_input(delta):
	var index
	var loss = 1.0 - delta * 10
	if senses.bitmask & Data.Sense.HUNGER:
		index = ai.sense_bit_to_index[Data.Sense.HUNGER]
		nn_input_array[index] = (max_energy - energy) / max_energy
	if senses.bitmask & Data.Sense.VISION_RAY_EATS:
		index = ai.sense_bit_to_index[Data.Sense.VISION_RAY_EATS]
		for i in range(vision_rays.size()):
			nn_input_array[index+i] *= loss
			var dist = vision_rays[i].collision_distance()
			if dist < 2:
				nn_input_array[index+i] = 1.0 - dist / 2.0
	if senses.bitmask & Data.Sense.DANGER_SENSE:
		index = ai.sense_bit_to_index[Data.Sense.DANGER_SENSE]
		var activations = $DangerSense.get_activations()
		for i in range(danger_sense_parts):
			nn_input_array[index + i] *= loss
			nn_input_array[index + i] = max(nn_input_array[index + i], activations[i])
	if senses.bitmask & Data.Sense.TIMER:
		index = ai.sense_bit_to_index[Data.Sense.TIMER]
		nn_input_array[index] = timer_neuron.neuron_value()
	if senses.bitmask & Data.Sense.THIRST:
		index = ai.sense_bit_to_index[Data.Sense.THIRST]
		nn_input_array[index] = (max_water - water) / max_water
	if senses.bitmask & Data.Sense.WATER_RAY:
		index = ai.sense_bit_to_index[Data.Sense.WATER_RAY]
		nn_input_array[index] = 1.0 - $WaterRay.collision_distance() / 2.0
	if senses.bitmask & Data.Sense.GROUND:
		index = ai.sense_bit_to_index[Data.Sense.GROUND]
		nn_input_array[index] = 1 - ground_movement_penalty_factor
		nn_input_array[index + 1] = $TerrainSense.resistance_ahead
	if senses.bitmask & Data.Sense.ALLY_SENSE:
		index = ai.sense_bit_to_index[Data.Sense.ALLY_SENSE]
		var activations = $AllySense.get_activations()
		for i in range(danger_sense_parts):
			nn_input_array[index + i] *= loss
			nn_input_array[index + i] = max(nn_input_array[index + i], activations[i])

		
# ==========================================================================
# Drawing methods
# ==========================================================================

func _draw():
	if selected:
		draw_selection()
	match draw_body_type:
		BodyType.ROUND: draw_round_body()
		BodyType.HEXAGONAL: draw_hexagonal_body()
	if draw_ears:
		draw_ears()

func draw_corner(corner: Vector2, add: Vector2):
	var offset = 3
	var color = Color(1, 0, 0)
	var from = corner + add * offset
	var length = (radius + offset * 2) / 3
	draw_line(from, from - Vector2(add.x, 0) * length, color, 2, true)
	draw_line(from, from - Vector2(0, add.y) * length, color, 2, true)
	
func draw_selection():
	for x in [-1, 1]:
		for y in [-1, 1]:
			var corner = Vector2(x, y) * radius
			draw_corner(corner, Vector2(x, y))
	
func _get_hexagon(size, center=Vector2.ZERO):
	var points = []
	for deg in range(30, 360, 60):
		points.append(Vector2(cos(deg2rad(deg)), sin(deg2rad(deg))) * size)
	return points
	
func draw_hexagonal_body():	
	var boppie_color = Color.white
	var shadow_color = Color(0, 0, 0, .02)
	var adjusted_radius = radius * 1.1
	for i in range(3):
		draw_colored_polygon(_get_hexagon(adjusted_radius + 4 - i, Vector2(-1, 0)), shadow_color)
		shadow_color.a *= 2
	draw_colored_polygon(_get_hexagon(adjusted_radius - armor), boppie_color.darkened(.4))
	draw_colored_polygon(_get_hexagon(adjusted_radius), boppie_color)

func draw_round_body():	
	var boppie_color = Color.white
	var shadow_color = Color(0, 0, 0, .02)
	for i in range(3):
		draw_circle(Vector2(-1, 0), radius + 4 - i, shadow_color)
		shadow_color.a *= 2
	draw_circle(Vector2.ZERO, radius, boppie_color.darkened(.4))
	draw_circle(Vector2.ZERO, radius - armor, boppie_color)
		
func draw_ears():
	var ears_start_point = Vector2(0, -15)
	var ears_end_point = Vector2(0, 18)
	var adjust = Vector2(-radius+armor, 0)
	draw_colored_polygon([ears_start_point, $Face.pos * 2, ears_end_point, adjust], Color.white)
	draw_colored_polygon([-ears_start_point, $Face.pos_other * 2, -ears_end_point, adjust], Color.white)

func set_selected(select):
	selected = select
	self.update()
	
func set_hovered(new_value):
	if hovered != new_value:
		hovered = new_value
		self.modulate = self.modulate.darkened(.3) if hovered else Color.white
		
func current_boppie_color(value):
	var darken = max(0, (max_water - water) / max_water - 0.5)
	return color.energy_gradient.interpolate(value).darkened(darken)
		
		
# ==========================================================================
# Movement
# ==========================================================================

func rotation_vector():
	return Vector2(cos(self.rotation), sin(self.rotation))

func move(factor, delta):
	var rot = rotation_vector()
	$Face.scale_eyes(factor)
	var armor_factor = (10 - armor) / 10
	var velocity = rot * factor * move_speed * armor_factor * ground_movement_penalty_factor / scale
	self.move_and_slide(velocity, Vector2.UP)
	
	
func turn(factor, delta):
	$Face.rotate_pupils(factor * turn_speed)
	self.rotation += factor * turn_speed * delta 

	
func _physics_process(delta):
	if not self.dead:
		update_energy(-delta * energy_consumption_existing * no_food_eaten_penalty)
		update_water(-delta * water_consumption_existing * no_food_eaten_penalty)
		if (water >= 0 and energy >= 0) or not can_die:
			var curr_ai = ai if temp_ai == null else temp_ai
			if curr_ai:
				calculate_ai_input(delta)
				movement = clamp(curr_ai.get_movement_factor(), max_backwards_factor, max_boost_factor)
				var turn = curr_ai.get_turn_factor()
				# Flip turning when movement is backwards
				turn = clamp(turn * turn_speed, -1, 1) * (1 if movement >= 0 else -1)
				update_energy(-delta * movement * movement * energy_consumption_walking)
				self.move(movement, delta)
				self.turn(turn, delta)
			if curr_ai == temp_ai:
				ai.get_movement_factor()
		else:
			die()
		self.self_modulate = current_boppie_color(self.energy / (max_energy * .7))
		$WalkingParticles.modulate = self_modulate
		$Face.get_node("AboveFace").self_modulate = self_modulate
		$Face.get_node("BelowFace").self_modulate = self_modulate
		$Hair.modulate = self_modulate
	

		
		
# ==========================================================================
# Life and death
# ==========================================================================

func die():
	if can_die:
		self.dead = true
		$DeathParticles.emitting = true
		$Face.eyes_dead()
		$Tween.interpolate_property(self, "modulate:a",
			1.0, 0.0, 1.0,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT
		)
		$Tween.start()
		yield(get_tree().create_timer(1.0), "timeout")
		emit_signal("BoppieDied", self)
		queue_free()

func curr_level():
	return int(offspring_energy / required_offspring_energy)
	
func update_water(add_water):
	water = min(max_water, water+add_water)
		
func update_energy(add_energy):
	#var reward_factor = add_energy * abs(add_energy) / 1000.0
	#if reward_factor > 0.01:
	#	ai.strengthen_important_connections(reward_factor)
	energy += add_energy
	if energy > max_energy:
		var old_level = curr_level()
		offspring_energy += energy - max_energy
		energy = max_energy
		if old_level != curr_level():
			if curr_level() < size_increases.size():
				level_up(size_increases[curr_level()] * scale_factor)
			else:
				produce_offspring()
				
func take_damage(damage) -> float:
	if dead:
		return 0.0
	else:
		var actual_damage = min(damage - armor, energy)
		$BloodParticles.amount = max(1.0, actual_damage * actual_damage)
		$BloodParticles.emitting = true
		update_energy(-actual_damage)
		return actual_damage
			
func level_up(new_scale):
	level += 1
	$Tween.interpolate_property(self, "scale",
		scale, Vector2(new_scale, new_scale), .5,
		Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	$Tween.start()
			
func produce_offspring():
	offspring_count += 1
	emit_signal("BoppieOffspring", self)
	
func eat(food):
	no_food_eaten_penalty = max(0.5, no_food_eaten_penalty * 0.7)
	times_eaten += 1
	var effectiveness = meat_tolerance if food.food_type == Data.FoodType.MEAT else 1 - meat_tolerance
	update_energy(food.nutrition * effectiveness)
	
func fitness():
	return (Globals.elapsed_time - spawn_time) * difficulty
