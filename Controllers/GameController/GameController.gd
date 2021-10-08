extends Node2D


class BoppieConfiguration:
	var group
	var boppie_class
	var min_count
	var scene
	func _init(group: String, boppie_class, min_count: int, scene: PackedScene):
		self.group = group
		self.boppie_class = boppie_class
		self.min_count = min_count
		self.scene = scene
		
var boppie_configurations = [
	BoppieConfiguration.new("Owlie", Owlie, 10, preload("res://Entities/Boppie/Types/Owlie.tscn")),
	BoppieConfiguration.new("Kloppie", Kloppie, 3, preload("res://Entities/Boppie/Types/Kloppie.tscn")),
]
var lookup_boppie_class_to_scene = {}

# Simulation settings
export var max_food_count = 200
export var food_per_500ms = 7
export var spawn_food_on_death = false

# Game size
export var total_width = 2000
export var total_height = 2000
export var empty_zone_size = 100
var total_size = Vector2(total_width, total_height)
var world_zone_start = Vector2(empty_zone_size, empty_zone_size)
var world_zone_end = total_size - world_zone_start 
var unused_food_stack = []
var unused_food_stack_index = 0

# Boppies
var food_scene = preload("res://Entities/Food/Food.tscn")
var controlled_boppie: Boppie = null
var player_ai = Player.new()

signal EngineTimeScaleChange(factor)

func random_coordinate():
	return Vector2(Globals.rng.randf(), Globals.rng.randf())

func random_world_coordinate():
	return random_coordinate() * (world_zone_end - world_zone_start) + world_zone_start
	
func random_game_coordinate():
	return random_coordinate() * total_size

func is_within_game(pos: Vector2):
	return (world_zone_start.x <= pos.x and pos.x <= world_zone_end.x
			and world_zone_start.y <= pos.y and pos.y <= world_zone_end.y)
	
func make_within_game(pos: Vector2):
	return Vector2(fposmod(pos.x, total_width), fposmod(pos.y, total_height))
	
func _draw():
	var offset = Vector2(14, 14)
	draw_rect(Rect2(-offset, total_size+offset), Color("#4d4d4d"))


func _ready():
	for boppie in get_tree().get_nodes_in_group("Boppie"):
		handle_boppie(boppie)
	$Camera.position = total_size / 2
	if food_per_500ms > 0:
		$FoodTimer.connect("timeout", self, "_reset_food_timer")
	for config in boppie_configurations:
		lookup_boppie_class_to_scene[config.boppie_class] = config.scene
		
func _reset_food_timer():
	spawn_food(food_per_500ms)
#	print(unused_food_stack_index)
#	var new_index = max(0, unused_food_stack_index - food_per_100ms)
#	for i in range(unused_food_stack_index, new_index, -1):
#		unused_food_stack[i].global_position = random_world_coordinate()
#		unused_food_stack[i].reset()
#	unused_food_stack_index = new_index
		
		
func handle_boppie(boppie):
	for signal_name in ["Clicked", "Died", "Offspring"]:
		boppie.connect("Boppie" + signal_name, self, "_on_Boppie" + signal_name)
	boppie.update()
		

func add_boppie(at: Vector2, scene: PackedScene, parent = null):
	var instance = scene.instance()
	var weights = null
	if parent != null:
		var nn = parent.ai if parent.ai is NeuralNetwork else parent.orig_ai
		weights = nn.get_mutated_weights(instance.offspring_mutability)
		instance.rotation = parent.rotation
	else:
		instance.rotation = Globals.rng.randf() * 2 * PI
	instance.add_temp_ai(NeuralNetwork.new(weights))
	#	instance.add_temp_ai(SmartAI.new())
	add_child(instance)
	instance.global_position = at
	handle_boppie(instance)
	

func add_random_boppies(count: int, scene: PackedScene):
	for _i in range(count):
		add_boppie(random_world_coordinate(), scene)
		
		
func add_food(at: Vector2):
	var food = food_scene.instance()
	add_child(food)
	food.global_position = at
	food.connect("FoodEaten", self, "_on_FoodEaten")
	return food
	
func _on_FoodEaten(food):
	unused_food_stack[unused_food_stack_index] = food
	unused_food_stack_index += 1


func spawn_food(count=max_food_count):
	var target_food_count = min(max_food_count, Globals.current_food_count + count)
	while Globals.current_food_count < target_food_count:
		add_food(random_world_coordinate())

func take_control_of_boppie(boppie):
	if controlled_boppie != null:
		controlled_boppie.set_selected(false)
		if controlled_boppie.ai == player_ai:
			controlled_boppie.pop_temp_ai()
	controlled_boppie = boppie
	if controlled_boppie != null:
		controlled_boppie.set_selected(true)


func _process(delta):
	check_boppies()
	if controlled_boppie:
		$Camera.global_position = controlled_boppie.global_position
	else:
		$Camera.global_position -= Utils.input_vectors() * 7

	
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		take_control_of_boppie(null)
	if event.is_action_pressed("ui_eat"):
		if controlled_boppie:
			controlled_boppie.update_energy(5)
	if event.is_action_pressed("ui_toggle_rays"):
		Globals.draw_vision_rays = !Globals.draw_vision_rays
	if event.is_action_pressed("toggle_performance_mode"):
		Globals.performance_mode = !Globals.performance_mode
	if event.is_action_pressed("ui_increase_time"):
		change_time_scale(2)
	if event.is_action_pressed("ui_decrease_time"):
		change_time_scale(0.5)
	if event.is_action_pressed("ui_pause"):
		get_tree().paused = !get_tree().paused
		emit_signal("EngineTimeScaleChange", int(!get_tree().paused))
	if event.is_action_pressed("take_control_of_boppie"):
		if controlled_boppie != null:
			if controlled_boppie.ai != player_ai:
				controlled_boppie.add_temp_ai(player_ai)
			else:
				controlled_boppie.pop_temp_ai()

func change_time_scale(factor):
	var new_time_scale = Engine.time_scale * factor
	if .5 <= new_time_scale and new_time_scale <= 256:
		Engine.time_scale = new_time_scale
		Engine.iterations_per_second = 60 * max(1, pow(2, log(Engine.time_scale)))
		emit_signal("EngineTimeScaleChange", factor)
			
func check_boppies():
	for config in boppie_configurations:
		var boppies = get_tree().get_nodes_in_group(config.group)
		for boppie in boppies:
			if not is_within_game(boppie.global_position):
				boppie.global_position = make_within_game(boppie.global_position)
		var diff = config.min_count - boppies.size()
		if diff > 0:
			Globals.boppies_spawned += diff
			add_random_boppies(diff, config.scene)
		
		
func _on_BoppieClicked(boppie):
	take_control_of_boppie(boppie)
	
func _on_BoppieDied(boppie):
	Globals.boppies_died += 1
	if boppie == controlled_boppie:
		take_control_of_boppie(null)
	if spawn_food_on_death:
		var food = food_scene.instance()
		food.global_position = boppie.global_position
		food.modulate = food.modulate.darkened(.3)
		add_child(food)
	
func _on_BoppieOffspring(boppie):
	Globals.boppies_born += 1
	var offspring_position = boppie.global_position - boppie.rotation_vector() * boppie.radius * 2.7
	var scene
	for config in boppie_configurations:
		if boppie is config.boppie_class:
			scene = config.scene
			break
	call_deferred("add_boppie", offspring_position, scene, boppie)
