extends Label

func _process(delta):
	self.text = "#" + str(get_tree().get_nodes_in_group("Boppie").size())
