extends KinematicBody2D

class_name Boppie

export var radius = 20
export var move_speed = 10000
export var turn_speed = 2
export var dead = false
export var ray_count_additional = 1
export var ray_angle = deg2rad(30)
export var ray_length = 120

var vision_rays = []

var energy = 8 + randf() * 4
var max_energy = 15

var ai = null
var orig_ai = null

var energy_gradient: Gradient = load("res://Entities/Boppie/EnergyGradient.tres")
var selected = false setget set_selected
var hovered = false setget set_hovered

signal BoppieClicked(Boppie)
signal BoppieDied(Boppie)

func _init(ai = null):
	if ai == null:
		ai = load("res://Controllers/AIs/AI.tscn").instance()
	self.ai = ai

	
func _ready():
	var start_angle = 0
	add_ray(start_angle, $VisionRay)
	for i in range(1, ray_count_additional+1):
		add_ray(start_angle + ray_angle * i)
		add_ray(start_angle - ray_angle * i)
	
func add_ray(angle_radians, ray=null):
	if ray == null:
		ray = $VisionRay.duplicate()
	ray.cast_to = Vector2(cos(angle_radians), sin(angle_radians)) * ray_length
	self.vision_rays.append(ray)
	add_child(ray)
	
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
	draw_line(from, from - Vector2(add.x, 0) * length, color, 1, true)
	draw_line(from, from - Vector2(0, add.y) * length, color, 1, true)
	
func draw_selection():
	for x in [-1, 1]:
		for y in [-1, 1]:
			var corner = Vector2(x, y) * radius
			draw_corner(corner, Vector2(x, y))

func _draw():
	if selected:
		draw_selection()
	var boppie_color = self.modulate
	if hovered:
		boppie_color = boppie_color.darkened(.3)
	draw_circle(Vector2.ZERO, radius, boppie_color)
	
	draw_circle(Vector2.ZERO, 3, Color(1, 0, 0))
	draw_line(Vector2.ZERO, Vector2(radius, 0), Color(0, 0, 0))
	
	
func set_selected(select):
	selected = select
	self.update()
	
func set_hovered(hover):
	hovered = hover
	self.update()
	
func rotation_vector():
	return Vector2(cos(self.rotation), sin(self.rotation))

func move(factor, delta):
	var rot = rotation_vector()
	var eyes_scale = clamp(factor, 1, 1.2)
	$Eyes.scale = Vector2(eyes_scale, eyes_scale)
	self.move_and_slide(rot * factor * move_speed * delta, Vector2.UP)
	
	
func turn(factor, delta):
	$Eyes.rotate_pupils(factor * turn_speed)
	self.rotation += factor * turn_speed * delta
	
	
func _physics_process(delta):
	if not self.dead:
		self.energy -= delta
		if energy >= 0:
			if ai:
				var movement = ai.get_movement_factor()
				self.energy -= delta * movement * movement
				self.move(movement, delta)
				self.turn(ai.get_turn_factor(), delta)
		else:
			die()
		self.self_modulate = energy_gradient.interpolate(self.energy / (max_energy * .7))
		
func die():
	self.dead = true
	emit_signal("BoppieDied", self)
	$DeathParticles.emitting = true
	$Eyes.eyes_dead()
	pop_temp_ai()
	yield(get_tree().create_timer(1.0), "timeout")
	queue_free()

func _on_Boppie_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("BoppieClicked", self)
		
func eat(food):
	self.energy = min(self.energy + food.nutrition, self.max_energy)
	

func _on_Boppie_mouse_entered():
	set_hovered(true)


func _on_Boppie_mouse_exited():
	set_hovered(false)
