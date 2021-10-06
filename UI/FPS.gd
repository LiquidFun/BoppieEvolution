extends Label

var prev_msec = 0
var prev_physics_frames = 0

func _ready():
	Globals.connect("HalfSecondTimer", self, "_on_HalfSecondTimer")
		
func _on_HalfSecondTimer():
	var fps = Engine.get_frames_per_second()
	var tps = 1000 * (Engine.get_physics_frames() - prev_physics_frames) / (OS.get_ticks_msec() - prev_msec)
	text = "%d FPS        %d/%d TPS" % [fps, tps, Engine.iterations_per_second]
	
	prev_msec = OS.get_ticks_msec()
	prev_physics_frames = Engine.get_physics_frames()
