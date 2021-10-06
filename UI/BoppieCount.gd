extends Label

func _process(_delta):
	text = ""
	text += "      #%d" % get_tree().get_nodes_in_group("Boppie").size()
	text += "      B: %d" % Globals.boppies_born
	text += "      D: %d" % Globals.boppies_died
	text += "      S: %d" % Globals.boppies_spawned
