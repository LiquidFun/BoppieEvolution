extends Button

onready var game_controller = get_tree().get_nodes_in_group("GameController")[0]

func _on_BoppieControlChanged(new_boppie):
	if new_boppie == null:
		self.text = "Take Control"
		self.pressed = false

func _ready():
	game_controller.connect("BoppieControlChanged", self, "_on_BoppieControlChanged")

func _on_TakeControl_pressed() -> void:
	if game_controller.take_control_of_focused_boppie():
		self.text = "Lose Control"
	else:
		self.text = "Take Control"
