extends Label


func _ready():
	while true:
		var old_physics_frames = Engine.get_physics_frames()
		var start_time = OS.get_ticks_msec()
		yield(get_tree().create_timer(Engine.time_scale), "timeout")
		
		text = str(Engine.get_frames_per_second()) + " FPS " 
		var now = OS.get_ticks_msec()
		text += str(1000 * (Engine.get_physics_frames() - old_physics_frames) / (now - start_time))
		text += "/" + str(Engine.iterations_per_second) + " PFPS"
