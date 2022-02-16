extends Node2D


class BoppieConfiguration:
	var group
	var min_count
	var scene
	var fittest: Array = []
	var new_dna_chance = 0.2
	func _init(group: String, min_count: int, scene: PackedScene):
		self.group = group
		self.min_count = min_count
		self.scene = scene
		
export var min_count_config = {
	"Owlie": 10,
	"Kloppie": 0,
	"Trap": 5,
}

func get_min_count(type):
	return min_count_config[type] if type in min_count_config else 0
		
onready var boppie_configurations = [
	BoppieConfiguration.new("Owlie", get_min_count("Owlie"), preload("res://Entities/Boppie/Types/Owlie.tscn")),
	BoppieConfiguration.new("Kloppie", get_min_count("Kloppie"), preload("res://Entities/Boppie/Types/Kloppie.tscn")),
	BoppieConfiguration.new("Trap", get_min_count("Trap"), preload("res://Entities/Trap/Trap.tscn")),
]
var lookup_boppie_type_to_config = {}

# Simulation settings
export var max_food_count = 150
export var food_per_500ms = 7
export var spawn_food_on_death = false
export var keep_n_fittest_boppies = 30
export var kloppies_cannibals = false

# Game size
export var total_width = 4000
export var total_height = 3000
export var empty_zone_size = 20
onready var total_size = Vector2(total_width, total_height)
onready var world_zone_start = Vector2(empty_zone_size, empty_zone_size)
onready var world_zone_end = total_size - world_zone_start 
var unused_food_stack = []
var unused_food_stack_index = 0
var follow_fittest_boppie = false setget set_follow_fittest_boppie
var difficulty_level = 1
var last_difficulty_level_change_time = 0
var mouse_is_pressed = false
var control_newest_boppie = false

export var background_color = Color("#6d6d6d")

# Boppies
var food_scene = preload("res://Entities/Food/Food.tscn")
var controlled_boppie: Boppie = null
var player_ai = Player.new()



signal FollowFittestBoppie(new_value)
signal EngineTimeScaleChange(factor)
signal BoppieControlChanged(boppie)
signal SpawnNewBoppie(at, dna)

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
	
func get_mouse_world_coords():
	var pos = get_global_mouse_position()
	return pos
	
func _draw():
	var offset = Vector2(14, 14)
	draw_rect(Rect2(-offset, total_size+offset), background_color)

func _ready():
	Globals.kloppies_cannibals = kloppies_cannibals
	for boppie in get_tree().get_nodes_in_group("Boppie"):
		handle_boppie(boppie)
	$Camera.position = total_size / 2
	if food_per_500ms > 0:
		$FoodTimer.connect("timeout", self, "_reset_food_timer")
	for config in boppie_configurations:
		lookup_boppie_type_to_config[config.group] = config
	connect("SpawnNewBoppie", self, "_on_SpawnNewBoppie")
		
func _reset_food_timer():
	spawn_food(food_per_500ms * 2)
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
		
func _on_SpawnNewBoppie(at, dna):
	add_boppie(at, boppie_configurations[0].scene, dna)

func add_boppie(at: Vector2, scene: PackedScene, dna=null):
	var instance = scene.instance()
	if instance is Boppie:
		if dna != null:
			instance.set_dna(dna, 1)
		handle_boppie(instance)
	instance.rotation = Globals.rng.randf() * 2 * PI
	add_child(instance)
	instance.global_position = at
	if control_newest_boppie:
		control_newest_boppie = false
		take_control_of_boppie(instance)
	return instance
	

func add_random_boppies(count: int, config: BoppieConfiguration):
	for _i in range(count):
		var old_dna = null
		if config.fittest.size() == keep_n_fittest_boppies and Globals.rng.randf() > config.new_dna_chance:
			old_dna = config.fittest[Globals.rng.randi() % keep_n_fittest_boppies][1]
		add_boppie(random_world_coordinate(), config.scene, old_dna)
		
		
func add_food(at: Vector2):
	var food = food_scene.instance()
	add_child(food)
	food.global_position = at
	# food.connect("FoodEaten", self, "_on_FoodEaten")
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
		controlled_boppie.draw_vision_rays = false
		if controlled_boppie.temp_ai == player_ai:
			controlled_boppie.pop_temp_ai()
	controlled_boppie = boppie
	emit_signal("BoppieControlChanged", controlled_boppie)
	if controlled_boppie != null:
		controlled_boppie.draw_vision_rays = Globals.draw_current_vision_rays
		controlled_boppie.set_selected(true)


func _process(delta):
	check_boppies()
	if controlled_boppie != null:
		$Camera.global_position = controlled_boppie.global_position
	else:
		$Camera.global_position -= Utils.input_vectors() * 7

	
func _unhandled_input(event):
	if event.is_action_pressed("cancel"):
		take_control_of_boppie(null)
	if event.is_action_pressed("add_energy_to_focused_boppie"):
		if controlled_boppie:
			controlled_boppie.update_energy(5)
	if event.is_action_pressed("produce_and_focus_offspring"):
		if controlled_boppie:
			controlled_boppie.produce_offspring()
			control_newest_boppie = true
	if event.is_action_pressed("toggle_vision_rays"):
		Globals.draw_vision_rays = !Globals.draw_vision_rays
	if event.is_action_pressed("toggle_vision_rays_of_focused_boppie"):
		Globals.draw_current_vision_rays = !Globals.draw_current_vision_rays
		if controlled_boppie != null:
			controlled_boppie.draw_vision_rays = Globals.draw_current_vision_rays
	if event.is_action_pressed("toggle_performance_mode"):
		Globals.performance_mode = !Globals.performance_mode
	if event.is_action_pressed("increase_time_factor"):
		change_time_scale(2)
	if event.is_action_pressed("decrease_time_factor"):
		change_time_scale(0.5)
	if event.is_action_pressed("set_time_factor_to_2^(number-1)"):
		var new_time_scale = 1 << (event.scancode - KEY_1)
		change_time_scale(new_time_scale / Engine.time_scale)
	if event.is_action_pressed("save_simulation"):
		$SaveDialog.show(true)
	if event.is_action_pressed("load_simulation"):
		$SaveDialog.show(false)
	if event.is_action_pressed("follow_fittest_boppie_after_death"):
		set_follow_fittest_boppie(!follow_fittest_boppie)
	if event.is_action_pressed("follow_fittest_owlie"):
		take_control_of_fittest_boppie_in_group("Owlie")
	if event.is_action_pressed("follow_fittest_kloppie"):
		take_control_of_fittest_boppie_in_group("Kloppie")
	if event.is_action_pressed("pause_simulation"):
		get_tree().paused = !get_tree().paused
		emit_signal("EngineTimeScaleChange", int(!get_tree().paused))
	if event.is_action_pressed("take_control_of_focused_boppie"):
		if controlled_boppie != null:
			if controlled_boppie.temp_ai != player_ai:
				controlled_boppie.add_temp_ai(player_ai)
			else:
				controlled_boppie.pop_temp_ai()
	if event is InputEventMouseButton:
		mouse_is_pressed = event.pressed
	elif event is InputEventMouseMotion and mouse_is_pressed:
		$Camera.position -= event.relative * $Camera._zoom_level

				
func find_fittest_in_group(group):
	var fittest = null
	for boppie in get_tree().get_nodes_in_group(group):
		if not boppie.dead and (fittest == null or boppie.spawn_time < fittest.spawn_time):
			fittest = boppie
	return fittest
	
func set_follow_fittest_boppie(value):
	follow_fittest_boppie = value
	emit_signal("FollowFittestBoppie", follow_fittest_boppie)
	
func take_control_of_fittest_boppie_in_group(group):
	# Use this function so it can be deferred
	set_follow_fittest_boppie(true)
	take_control_of_boppie(find_fittest_in_group(group))

func change_time_scale(factor):
	var new_time_scale = Engine.time_scale * factor
	if .5 <= new_time_scale and new_time_scale <= 256 and new_time_scale != Engine.time_scale:
		Engine.time_scale = new_time_scale
		Engine.iterations_per_second = 60 * max(1, pow(2, log(Engine.time_scale)))
		if new_time_scale >= 64:
			Globals.performance_mode = true
		emit_signal("EngineTimeScaleChange", factor)
			
func check_boppies():
	for config in boppie_configurations:
		var boppies = get_tree().get_nodes_in_group(config.group)
		if Globals.elapsed_time - last_difficulty_level_change_time > 300:
			if difficulty_level < 2 and boppies.size() > 40:
				lookup_boppie_type_to_config["Kloppie"].min_count = 3
				difficulty_level += 1
				last_difficulty_level_change_time = Globals.elapsed_time
				Globals.difficulty += .1
				config.new_dna_chance = 1 - ((1 - config.new_dna_chance) * .9)
		for boppie in boppies:
			if not is_within_game(boppie.global_position):
				boppie.global_position = make_within_game(boppie.global_position)
		var diff = config.min_count - boppies.size()
		if diff > 0:
			Globals.boppies_spawned += diff
			add_random_boppies(diff, config)
			
func possibly_replace_weakest_boppie(boppie):
	if boppie.offspring_count == 0:
		return
	var fittest_boppies = lookup_boppie_type_to_config[boppie.type].fittest
	var tuple = [boppie.fitness(), boppie.dna.duplicate(true)]
	if fittest_boppies.size() < keep_n_fittest_boppies:
		fittest_boppies.append(tuple)
		return
	var weakest_index = 0
	for index in range(fittest_boppies.size()):
		if fittest_boppies[weakest_index][0] > fittest_boppies[index][0]:
			weakest_index = index
	if fittest_boppies[weakest_index][0] < tuple[0]:
		fittest_boppies[weakest_index] = tuple

func _on_BoppieClicked(boppie):
	take_control_of_boppie(boppie)
	
func _on_BoppieDied(boppie):
	Globals.boppies_died += 1
	# possibly_replace_weakest_boppie(boppie)
	if boppie == controlled_boppie:
		if follow_fittest_boppie:
			take_control_of_fittest_boppie_in_group(boppie.type)
		else:
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
		if boppie.type == config.group:
			scene = config.scene
			break
	call_deferred("add_boppie", offspring_position, scene, boppie.dna)


func _on_TrackFittestTimer_timeout() -> void:
	if not get_tree().paused:
		for config in boppie_configurations:
			if config.group == "Trap":
				continue
			var boppie = find_fittest_in_group(config.group)
			if boppie != null and boppie.offspring_count > 0:
				config.fittest.push_front([boppie.fitness(), boppie.dna.duplicate(true)])
				if len(config.fittest) > keep_n_fittest_boppies:
					config.fittest.pop_back()
