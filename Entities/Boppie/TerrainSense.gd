extends Area2D

var resistance_ahead = 0

func _on_TerrainSense_area_entered(area: Area2D) -> void:
	resistance_ahead = area.resistance


func _on_TerrainSense_area_exited(area: Area2D) -> void:
	resistance_ahead = 0
