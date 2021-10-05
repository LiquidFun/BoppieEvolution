extends Label

func _process(delta):
	text = str(Engine.time_scale) + "x"
