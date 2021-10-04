extends Node2D


export(NodePath) var controlled_boppie_path_on_start = null

var boppie_scene = preload("res://Entities/Boppie/Boppie.tscn")
var controlled_boppie = null
var boppies = []

func _ready():
	if controlled_boppie_path_on_start != null:
		take_control_of_boppie(get_node(controlled_boppie_path_on_start))
	var boppies = get_tree().get_nodes_in_group("Boppie")
	for boppie in boppies:
		handle_boppie(boppie)
	add_random_boppies(100)
		
		
func handle_boppie(boppie):
	boppie.connect("BoppieClicked", self, "_on_BoppieClicked")
	boppie.update()
		

func add_boppie(at: Vector2):
	var instance = boppie_scene.instance()
	add_child(instance)
	instance.global_position = at
	handle_boppie(instance)
	print("added at", at)
	

func add_random_boppies(count: int):
	for i in range(count):
		add_boppie(Vector2(randf(), randf()) * 1000)


func take_control_of_boppie(boppie):
	if controlled_boppie != null:
		controlled_boppie.set_selected(false)
	controlled_boppie = boppie
	if controlled_boppie != null:
		controlled_boppie.set_selected(true)


func _process(delta):
	if controlled_boppie:
		var movement = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
		controlled_boppie.move(movement, delta)
		var rotation = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		controlled_boppie.turn(rotation, delta)
		$Camera.global_position = controlled_boppie.global_position
		
		
func _on_BoppieClicked(boppie):
	take_control_of_boppie(boppie)
	
