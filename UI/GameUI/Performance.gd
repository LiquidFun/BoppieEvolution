extends CheckBox

func _on_PerformanceModeChanged(new_value):
	pressed = new_value

func _ready():
	pressed = Globals.performance_mode
	Globals.connect("PerformanceModeChanged", self, "_on_PerformanceModeChanged")

func _on_Performance_toggled(button_pressed: bool) -> void:
	Globals.performance_mode = button_pressed
