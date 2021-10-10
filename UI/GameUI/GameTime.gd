extends Label

func _ready():
	$SecondTimer.connect("timeout", self, "_on_SecondTimerTimeout")
	$SecondTimer.start()
	
func _on_SecondTimerTimeout():
	text = Globals.formatted_time()
