extends KinematicBody2D

class_name Boppie

export var radius = 20
export var move_speed = 85
export var turn_speed = 2
export var dead = false
export var can_die = true
export var ray_count_additional = 2
export var ray_angle = deg2rad(20)
export var ray_length = 400

export var energy_consumption_existing = .5
export var energy_consumption_walking = .5

# up to 0.05 works well
export var offspring_mutability = 0.03

var vision_rays = []

var energy = 8 + randf() * 4
export var max_energy = 15
var offspring_energy = 0
export var required_offspring_energy = 10
var size_increases = [0.8, 1, 1.2]

var ai = null
var orig_ai = null

enum Data {ENERGY, RAY_DIST, RAY_TYPE}
enum Raytype {NONE, BOPPIE, FOOD}
export var ai_input = {}

var energy_gradient: Gradient = load("res://Entities/Boppie/EnergyGradient.tres")
var selected = false setget set_selected
var hovered = false setget set_hovered

signal BoppieClicked(Boppie)
signal BoppieOffspring(Boppie)
signal BoppieDied(Boppie)

func _init(ai = null):
	if ai == null:
		ai = AI.new()
	self.ai = ai
	
var scale_tween = Tween.new()

	
func _ready():
	add_child(scale_tween)
	scale_tween.interpolate_property(
		self, "scale", Vector2(.1, .1), Vector2(size_increases[0], size_increases[0]), 
		1, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT
	)
	scale_tween.start()
	$SpawnParticles.emitting = true
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

func _draw():
	if selected:
		draw_selection()
	var boppie_color = Color.white
	#if hovered:
	#	boppie_color = boppie_color.darkened(.3)
	var shadow_color = Color(0, 0, 0, .02)
	for i in range(3):
		draw_circle(Vector2(-1, 0), radius + 4 - i, shadow_color)
		shadow_color.a *= 2
	draw_circle(Vector2.ZERO, radius, boppie_color)
	var start_point = Vector2(0, -15)
	var end_point = Vector2(0, 18)
	
	# Draw ears
	draw_colored_polygon([start_point, $Eyes.pos * 2, end_point], boppie_color)
	draw_colored_polygon([-start_point, $Eyes.pos_other * 2, -end_point], boppie_color)
	
	# Draw nose
	# draw_circle(Vector2.ZERO, 3, Color(1, 0, 0))
	# draw_line(Vector2.ZERO, Vector2(radius, 0), Color(0, 0, 0))

	
	
func set_selected(select):
	selected = select
	self.update()
	
func set_hovered(new_value):
	
	if new_value != hovered:
		hovered = new_value
		if hovered:
			self.modulate = self.modulate.darkened(.3)
		else:
			self.modulate = Color.white
	
func rotation_vector():
	return Vector2(cos(self.rotation), sin(self.rotation))

func move(factor, delta):
	var rot = rotation_vector()
	$Eyes.scale_eyes(factor)
	var velocity = rot * factor * move_speed / scale
	self.move_and_slide(velocity, Vector2.UP)
	
	
func turn(factor, delta):
	$Eyes.rotate_pupils(factor * turn_speed)
	self.rotation += factor * turn_speed * delta 
	
	
func _physics_process(delta):
	if not self.dead:
		update_energy(-delta * energy_consumption_existing)
		if energy >= 0 or not can_die:
			if ai:
				calc_ai_input()
				var movement = ai.get_movement_factor(ai_input)
				movement = clamp(movement, -1, 2)
				var turn = ai.get_turn_factor(ai_input)
				turn = clamp(turn, -1, 1)
				update_energy(-delta * movement * movement * energy_consumption_walking)
				self.move(movement, delta)
				self.turn(turn, delta)
		else:
			die()
		self.self_modulate = energy_gradient.interpolate(self.energy / (max_energy * .7))
		$WalkingParticles.modulate = self_modulate
		$Hair.modulate = self_modulate
	

func calc_ai_input():
	ai_input[Data.ENERGY] = energy / max_energy
	for i in range(vision_rays.size()):
		ai_input[Data.RAY_DIST][i] = vision_rays[i].collision_distance()
		ai_input[Data.RAY_TYPE][i] = vision_rays[i].collision_type()

func die():
	if can_die:
		self.dead = true
		if not Globals.performance_mode:
			$DeathParticles.emitting = true
		$Eyes.eyes_dead()
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
			
func level_up(new_scale):
	$Tween.interpolate_property(self, "scale",
		scale, Vector2(new_scale, new_scale), .5,
		Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	$Tween.start()
			
func produce_offspring():
	emit_signal("BoppieOffspring", self)
	
func eat(food):
	update_energy(food.nutrition)
	

