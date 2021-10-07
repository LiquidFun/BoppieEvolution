extends Area2D

onready var parent = get_parent()


func _on_ClickableArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		parent.emit_signal("BoppieClicked", parent)


func _on_ClickableArea_mouse_entered():
	parent.set_hovered(true)


func _on_ClickableArea_mouse_exited():
	parent.set_hovered(false)
