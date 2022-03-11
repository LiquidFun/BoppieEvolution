extends HBoxContainer

func _ready():
	Globals.connect("HalfSecondTimer", self, "_on_HalfSecondTimer")
	
func _on_HalfSecondTimer():
	# text += "      #%d" % get_tree().get_nodes_in_group("Boppie").size()
	$Apples.text = str(Globals.current_food_count)
	$Born.text = str(Globals.boppies_born)
	$Died.text = str(Globals.boppies_died)
	$Spawned.text = str(Globals.boppies_spawned)
