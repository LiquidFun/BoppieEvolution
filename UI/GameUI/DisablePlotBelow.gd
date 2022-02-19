extends CheckBox

export(NodePath) var plot = null


func _ready() -> void:
	plot = get_node(plot)


func _on_DisablePlotBelow_toggled(button_pressed: bool) -> void:
	if plot != null:
		plot.visible = button_pressed
