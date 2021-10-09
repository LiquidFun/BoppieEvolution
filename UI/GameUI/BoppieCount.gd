extends Label

func _ready():
	Globals.connect("HalfSecondTimer", self, "_on_HalfSecondTimer")
	
func _on_HalfSecondTimer():
	text = ""
	text += "      #%d" % get_tree().get_nodes_in_group("Boppie").size()
	text += "      F: %d" % Globals.current_food_count
	text += "      B: %d" % Globals.boppies_born
	text += "      D: %d" % Globals.boppies_died
	text += "      S: %d" % Globals.boppies_spawned
