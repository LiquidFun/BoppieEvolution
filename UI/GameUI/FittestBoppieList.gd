extends ItemList

var game_controller
var dragging_boppie = null
var saved_collision_bits

func _ready():
	Globals.connect("HalfSecondTimer", self, "_on_HalfSecondTimer")
	for gc in get_tree().get_nodes_in_group("GameController"):
		game_controller = gc
		break
	

func _on_HalfSecondTimer():
	clear()
	for config in game_controller.boppie_configurations:
		add_item("Fittest " + config.group + "s", null, false)
		for fitness_and_dna in config.fittest:
			add_item(str(fitness_and_dna[0]))


func _on_Fittest_item_selected(index: int) -> void:
	for config in game_controller.boppie_configurations:
		index -= 1
		if 0 <= index and index < len(config.fittest):
			var dragging_dna = [config.scene, config.fittest[index][1]]
			var position = game_controller.get_local_mouse_position()
			dragging_boppie = game_controller.add_boppie(position, dragging_dna[0], dragging_dna[1])
			saved_collision_bits = [dragging_boppie.collision_layer, dragging_boppie.collision_mask]
			dragging_boppie.collision_layer = 0
			dragging_boppie.collision_mask = 0
			dragging_boppie.set_process(false)
			dragging_boppie.set_physics_process(false)
			return
		index -= len(game_controller.boppie_configurations)
		
func _process(delta: float) -> void:
	if dragging_boppie != null:
		dragging_boppie.position = game_controller.get_mouse_world_coords()

func _input(event):
	if dragging_boppie != null:
		if event is InputEventMouseButton and event.button_mask == 0:
			dragging_boppie.collision_layer = saved_collision_bits[0]
			dragging_boppie.collision_mask = saved_collision_bits[1]
			dragging_boppie.set_process(true)
			dragging_boppie.set_physics_process(true)
			dragging_boppie = null
