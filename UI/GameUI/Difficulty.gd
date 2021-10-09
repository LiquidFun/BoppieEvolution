extends Label

func _ready():
	Globals.connect("DifficultyChanged", self, "_on_DifficultyChanged")
	_on_DifficultyChanged(Globals.difficulty)
		
func _on_DifficultyChanged(new_value):
	self.text = "Difficulty: %.1f" % new_value
