extends Button

onready var game_controller = get_tree().get_nodes_in_group("GameController")[0]

func _on_FollowFittestBoppie(new_value):
	pressed = new_value

func _ready():
	game_controller.connect("FollowFittestBoppie", self, "_on_FollowFittestBoppie")


func _on_FollowFittest_toggled(button_pressed: bool) -> void:
	if button_pressed:
		game_controller.take_control_of_fittest_boppie_in_group("Owlie")
	else:
		game_controller.set_follow_fittest_boppie(false)
