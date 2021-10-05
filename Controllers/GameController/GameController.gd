extends Node2D

# Simulation settings
export var expected_food_count = 50
export var expected_boppie_count = 20
export var spawn_food_on_death = false

# Game size
export var total_width = 2000
export var total_height = 2000
export var empty_zone_size = 100
var total_size = Vector2(total_width, total_height)
var world_zone_start = Vector2(empty_zone_size, empty_zone_size)
var world_zone_end = total_size - world_zone_start 

# Boppies
var boppie_scene = preload("res://Entities/Boppie/Boppie.tscn")
var food_scene = preload("res://Entities/Food/Food.tscn")
var controlled_boppie: Boppie = null
var player_ai = Player.new()

func random_coordinate():
	return Vector2(randf(), randf())

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
	add_random_boppies(expected_boppie_count)
	$Camera.position = total_size / 2
		
		
func handle_boppie(boppie):
	for signal_name in ["Clicked", "Died", "Offspring"]:
		boppie.connect("Boppie" + signal_name, self, "_on_Boppie" + signal_name)
	boppie.update()
		

func add_boppie(at: Vector2):
	var instance = boppie_scene.instance()
	instance.add_temp_ai(SmartAI.new())
	instance.rotation = randf() * 2 * PI
	add_child(instance)
	instance.global_position = at
	handle_boppie(instance)
	

func add_random_boppies(count: int):
	for i in range(count):
		add_boppie(random_world_coordinate())
		
		
func add_food(at: Vector2):
	var instance = food_scene.instance()
	add_child(instance)
	instance.global_position = at
	

func keep_enough_food():
	while Globals.current_food_count < expected_food_count:
		add_food(random_world_coordinate())


func take_control_of_boppie(boppie):
	if controlled_boppie != null:
		controlled_boppie.set_selected(false)
		controlled_boppie.pop_temp_ai()
	controlled_boppie = boppie
	if controlled_boppie != null:
		controlled_boppie.set_selected(true)
		controlled_boppie.add_temp_ai(player_ai)


func _process(delta):
	handle_user_input()
	check_boppies()
	keep_enough_food()
	if controlled_boppie:
		$Camera.global_position = controlled_boppie.global_position
	else:
		$Camera.global_position -= Utils.input_vectors() * 5

	
func handle_user_input():
	if Input.is_action_just_pressed("ui_cancel"):
		take_control_of_boppie(null)
	if Input.is_action_just_pressed("ui_eat"):
		if controlled_boppie:
			controlled_boppie.eat(Food.new())
	if Input.is_action_just_pressed("ui_toggle_rays"):
		Globals.draw_vision_rays = !Globals.draw_vision_rays
	if Input.is_action_just_pressed("ui_increase_time"):
		if Engine.time_scale < 1000:
			Engine.time_scale *= 2
			Engine.iterations_per_second *= 1.6
	if Input.is_action_just_pressed("ui_decrease_time"):
		if Engine.time_scale > .25:
			Engine.time_scale /= 2
			Engine.iterations_per_second /= 1.6
	if Input.is_action_just_pressed("ui_pause"):
		get_tree().paused = !get_tree().paused
		

			
func check_boppies():
	var boppies = get_tree().get_nodes_in_group("Boppie")
	for boppie in boppies:
		if not is_within_game(boppie.global_position):
			boppie.global_position = make_within_game(boppie.global_position)
			
	add_random_boppies(expected_boppie_count - boppies.size())
		
		
func _on_BoppieClicked(boppie):
	take_control_of_boppie(boppie)
	
func _on_BoppieDied(boppie):
	if boppie == controlled_boppie:
		take_control_of_boppie(null)
	if spawn_food_on_death:
		var food = food_scene.instance()
		food.global_position = boppie.global_position
		add_child(food)
	
func _on_BoppieOffspring(boppie):
	add_boppie(boppie.global_position - boppie.rotation_vector() * boppie.radius)
