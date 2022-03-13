extends HBoxContainer

func _ready():
	Globals.connect("HalfSecondTimer", self, "_on_HalfSecondTimer")
	
func set_text_if_child(node_name, text):
	if has_node(node_name):
		get_node(node_name).text = str(text)
	
func _on_HalfSecondTimer():
	set_text_if_child("Alive", get_tree().get_nodes_in_group("Boppie").size())
	set_text_if_child("Apples", Globals.food_counts[Data.FoodType.PLANT])
	set_text_if_child("Meat", Globals.food_counts[Data.FoodType.MEAT])
	set_text_if_child("Born", Globals.boppies_born)
	set_text_if_child("Died", Globals.boppies_died)
	set_text_if_child("Spawned", Globals.boppies_spawned)
	

