extends Label

func _ready():
	$SecondTimer.connect("timeout", self, "_on_SecondTimerTimeout")
	$SecondTimer.start()
	
func _on_SecondTimerTimeout():
	var seconds = int($GameTimer.wait_time - $GameTimer.time_left)
	text = "%02d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60]
