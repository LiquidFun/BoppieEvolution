extends Node2D

var boppie_scene = preload("res://Entities/Boppie/Boppie.tscn")
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
		add_boppie(Vector2(randf(), randf()) * 1000)


func take_control_of_boppie(boppie):
	if controlled_boppie != null:
		controlled_boppie.set_selected(false)
		controlled_boppie.pop_temp_ai()
	controlled_boppie = boppie
	if controlled_boppie != null:
		controlled_boppie.set_selected(true)
		controlled_boppie.add_temp_ai(player_ai)


func _process(delta):
	if controlled_boppie:
		$Camera.global_position = controlled_boppie.global_position
		
		
func _on_BoppieClicked(boppie):
	take_control_of_boppie(boppie)
	
