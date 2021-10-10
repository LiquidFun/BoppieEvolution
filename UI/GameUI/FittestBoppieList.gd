extends ItemList

var game_controller

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
