extends Label

func _ready():
	for game_controller in get_tree().get_nodes_in_group("GameController"):
		game_controller.connect("FollowFittestBoppie", self, "_on_FollowFittestBoppie")
		
func _on_FollowFittestBoppie(new_value):
	self.text = "" if new_value else ""
