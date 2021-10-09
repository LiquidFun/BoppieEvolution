extends Label

func _ready():
	var game_controllers = get_tree().get_nodes_in_group("GameController")
	for game_controller in game_controllers:
		game_controller.connect("EngineTimeScaleChange", self, "_on_EngineTimeScaleChange")

func _on_EngineTimeScaleChange(factor):
	match min(2, factor):  # Warning! Each of these strings contains a fontawesome unicode icon, godot doesn't display them
		0.0: text = ""  # pause
		1.0: text = ""  # play
		2.0: text = ""  # double arrow right
		_: text = ""  # double arrow left
	$Tween.stop_all()
	var s = Engine.time_scale
	if factor != 1:
		$Tween.interpolate_property(self, "modulate:a", 0, 1, .2 * s, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	if factor != 0:
		$Tween.interpolate_property(self, "modulate:a", 1, 0, .4 * s, Tween.TRANS_SINE, Tween.EASE_IN_OUT, .3 * s)
	$Tween.start()
