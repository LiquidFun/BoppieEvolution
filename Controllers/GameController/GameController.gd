extends Node2D

export var expected_food_count = 100

var boppie_scene = preload("res://Entities/Boppie/Boppie.tscn")
var food_scene = preload("res://Entities/Food/Food.tscn")
var boppies = []
var controlled_boppie: Boppie = null
var player_ai = Player.new()

func _ready():
	var boppies = get_tree().get_nodes_in_group("Boppie")
	for boppie in boppies:
		handle_boppie(boppie)
	add_random_boppies(100)
		
		
func handle_boppie(boppie):
	boppie.connect("BoppieClicked", self, "_on_BoppieClicked")
	boppie.update()
		

func add_boppie(at: Vector2):
	var instance = boppie_scene.instance()
	instance.add_temp_ai(RandomAI.new())
	instance.rotation = randf() * 2 * PI
	add_child(instance)
	instance.global_position = at
	handle_boppie(instance)
	

func add_random_boppies(count: int):
	for i in range(count):
		add_boppie(random_coordinate())
		
	
func random_coordinate():
	return Vector2(randf(), randf()) * Globals.game_size
		
		
func add_food(at: Vector2):
	var instance = food_scene.instance()
	add_child(instance)
	instance.global_position = at
	

func keep_enough_food():
	while Globals.current_food_count < expected_food_count:
		add_food(random_coordinate())
		


func take_control_of_boppie(boppie):
	if controlled_boppie != null:
		controlled_boppie.set_selected(false)
		controlled_boppie.pop_temp_ai()
	controlled_boppie = boppie
	if controlled_boppie != null:
		controlled_boppie.set_selected(true)
		controlled_boppie.add_temp_ai(player_ai)


func _process(delta):
	keep_enough_food()
	if controlled_boppie:
		$Camera.global_position = controlled_boppie.global_position
	else:
		$Camera.global_position -= Globals.input_vectors() * 5
		
		
func _on_BoppieClicked(boppie):
	take_control_of_boppie(boppie)
	
