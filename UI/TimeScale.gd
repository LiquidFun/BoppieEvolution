extends Label

func _ready():
	var game_controllers = get_tree().get_nodes_in_group("GameController")
	for game_controller in game_controllers:
		game_controller.connect("EngineTimeScaleChange", self, "_on_EngineTimeScaleChange")

func _on_EngineTimeScaleChange(_factor):
	text = str(Engine.time_scale) + "x"
