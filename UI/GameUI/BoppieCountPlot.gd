extends TimePlot

func _ready() -> void:
	add_dataset("Owlies", Color.green)
	add_dataset("Kloppies", Color.blue)
	add_dataset("Food", Color(1, 0, 0, 0.3))
	
func replot():
	var owlies = get_tree().get_nodes_in_group("Owlie").size()
	add_point("Owlies", owlies)
	var kloppies = get_tree().get_nodes_in_group("Kloppie").size()
	add_point("Kloppies", kloppies)
	add_point("Food", Globals.current_food_count)
	update()
