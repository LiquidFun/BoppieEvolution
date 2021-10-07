extends Camera2D

# Script based on https://www.gdquest.com/tutorial/godot/2d/camera-zoom/
export var min_zoom := 0.2
export var max_zoom := 2.0
export var zoom_factor := 0.1
export var zoom_duration := 0.1

var _zoom_level := 1.0 setget _set_zoom_level

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		_set_zoom_level(_zoom_level - zoom_factor)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level + zoom_factor)
		
		
func _set_zoom_level(value: float):
	_zoom_level = clamp(value, min_zoom, max_zoom)
	$Tween.interpolate_property(
		self, "zoom", zoom,Vector2(_zoom_level, _zoom_level),
		zoom_duration, $Tween.TRANS_SINE, $Tween.EASE_OUT
	)
	$Tween.start()
