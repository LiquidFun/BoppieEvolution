extends CheckBox

func _ready():
	pressed = Globals.draw_senses

func _on_ShowVision_toggled(button_pressed: bool) -> void:
	Globals.draw_senses = button_pressed
