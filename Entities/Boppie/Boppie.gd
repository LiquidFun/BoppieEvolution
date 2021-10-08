extends KinematicBody2D

class_name Boppie

var radius := 20.0
var move_speed := 85.0
var turn_speed := 2.0
var can_die := true
var ray_count_additional := 2
var ray_angle := deg2rad(20)
var ray_length := 400.0
var nutrition := 30.0
var max_boost_factor := 2.0
var max_backwards_factor := -1.0
var movement = 0

var energy_consumption_existing = .5
var energy_consumption_walking = .5

# up to 0.05 works well
var offspring_mutability = 0.03

var vision_rays = []

var dead = false

var ai = null
var orig_ai = null

enum Data {ENERGY, RAY_DIST, RAY_TYPE, EATS}
enum Raytype {NONE, OWLIE, KLOPPIE, FOOD}
var ai_input = {}

var energy_gradient = "res://Entities/Boppie/DefaultEnergyGradient.tres"
var selected = false setget set_selected
var hovered = false setget set_hovered

enum BodyType {ROUND, HEXAGONAL}
var draw_body_type =  BodyType.ROUND
var draw_ears = false
var draw_eyebrows = false
var draw_eyes = true
var draw_nose = true
var draw_teeth = false
var draw_hair = false

var max_energy = 15
var required_offspring_energy = 10
var size_increases = [0.8, 1, 1.2]
var energy = max_energy * .8 + randf() * max_energy * .2
var offspring_energy = 0
var eats = Raytype.FOOD

signal BoppieClicked(Boppie)
signal BoppieOffspring(Boppie)
signal BoppieDied(Boppie)

func _init(ai=null):
	if ai == null:
		ai = AI.new()
	self.ai = ai
	
func _ready():
	energy_gradient = load(energy_gradient)
	$Tween.interpolate_property(
		self, "scale", Vector2(.2, .2), Vector2(size_increases[0], size_increases[0]), 
		1, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT
	)
	$Tween.start()
	$SpawnParticles.emitting = true
	ai_input[Data.EATS] = eats
	ai_input[Data.RAY_DIST] = []
	ai_input[Data.RAY_TYPE] = []
	var start_angle = 0
	add_ray(start_angle, true, $VisionRay)
	for i in range(1, ray_count_additional+1):
		add_ray(start_angle + ray_angle * i, true)
		add_ray(start_angle - ray_angle * i, true)

	
	
func add_ray(angle_radians, push_back=true, ray=null):
	if ray == null:
		ray = $VisionRay.duplicate()
		add_child(ray)
	ray.cast_to = Vector2(cos(angle_radians), sin(angle_radians)) * ray_length
	if push_back:
		self.vision_rays.push_back(ray)
	else:
		self.vision_rays.push_front(ray)
	ai_input[Data.RAY_DIST].append(1)
	ai_input[Data.RAY_TYPE].append(Raytype.NONE)

	
func add_temp_ai(ai):
	if ai:
		orig_ai = self.ai
		self.ai = ai
	
func pop_temp_ai():
	if orig_ai:
		self.ai = orig_ai
		orig_ai = null
		
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
	draw_colored_polygon(_get_hexagon(adjusted_radius), boppie_color)


func draw_round_body():	
	var boppie_color = Color.white
	var shadow_color = Color(0, 0, 0, .02)
	for i in range(3):
		draw_circle(Vector2(-1, 0), radius + 4 - i, shadow_color)
		shadow_color.a *= 2
	draw_circle(Vector2.ZERO, radius, boppie_color)
		
func draw_ears():
	var ears_start_point = Vector2(0, -15)
	var ears_end_point = Vector2(0, 18)
	draw_colored_polygon([ears_start_point, $Face.pos * 2, ears_end_point], Color.white)
	draw_colored_polygon([-ears_start_point, $Face.pos_other * 2, -ears_end_point], Color.white)


func set_selected(select):
	selected = select
	self.update()
	
func set_hovered(new_value):
	if hovered != new_value:
		hovered = new_value
		self.modulate = self.modulate.darkened(.3) if hovered else Color.white

func rotation_vector():
	return Vector2(cos(self.rotation), sin(self.rotation))

func move(factor, delta):
	var rot = rotation_vector()
	$Face.scale_eyes(factor)
	var velocity = rot * factor * move_speed / scale
	self.move_and_slide(velocity, Vector2.UP)
	
	
func turn(factor, delta):
	$Face.rotate_pupils(factor * turn_speed)
	self.rotation += factor * turn_speed * delta 
	
	
func _physics_process(delta):
	if not self.dead:
		update_energy(-delta * energy_consumption_existing)
		if energy >= 0 or not can_die:
			if ai:
				calc_ai_input()
				movement = clamp(ai.get_movement_factor(ai_input), max_backwards_factor, max_boost_factor)
				var turn = ai.get_turn_factor(ai_input)
				# Flip turning when movement is backwards
				turn = clamp(turn, -1, 1) * (1 if movement >= 0 else -1)
				update_energy(-delta * movement * movement * energy_consumption_walking)
				self.move(movement, delta)
				self.turn(turn, delta)
		else:
			die()
		self.self_modulate = energy_gradient.interpolate(self.energy / (max_energy * .7))
		$WalkingParticles.modulate = self_modulate
		$Face.get_node("AboveFace").self_modulate = self_modulate
		$Face.get_node("BelowFace").self_modulate = self_modulate
		$Hair.modulate = self_modulate
	

func calc_ai_input():
	ai_input[Data.ENERGY] = energy / max_energy
	for i in range(vision_rays.size()):
		ai_input[Data.RAY_DIST][i] = vision_rays[i].collision_distance()
		ai_input[Data.RAY_TYPE][i] = vision_rays[i].collision_type()

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
		
func update_energy(add_energy):
	energy += add_energy
	if energy > max_energy:
		var old_level = curr_level()
		offspring_energy += energy - max_energy
		energy = max_energy
		if old_level != curr_level():
			if curr_level() < size_increases.size():
				level_up(size_increases[curr_level()])
			else:
				produce_offspring()
				
func take_damage(damage):
	update_energy(-damage)
	return energy < 0
			
func level_up(new_scale):
	$Tween.interpolate_property(self, "scale",
		scale, Vector2(new_scale, new_scale), .5,
		Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	$Tween.start()
			
func produce_offspring():
	emit_signal("BoppieOffspring", self)
	
func eat(food):
	update_energy(food.nutrition)
	

