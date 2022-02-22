extends Node2D

class_name ParticlesManager


func _ready():
	self.visible = !Globals.performance_mode
	Globals.connect("PerformanceModeChanged", self, "_on_PerformanceModeChange")
	
func _on_PerformanceModeChange(new_value):
	self.visible = !new_value
