extends Label

func _ready():
	$SecondTimer.connect("timeout", self, "_on_SecondTimerTimeout")
	$SecondTimer.start()
	
func _on_SecondTimerTimeout():
	text = Globals.formatted_time()
	hint_tooltip = "Passed simulation time. Simulation started at: %s. Real time passed: %s." % [
		Globals.formatted_real_start_datetime(),
		Globals.formatted_real_time_passed(),
	]
