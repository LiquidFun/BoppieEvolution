extends Label

func _ready():
	self.text = "Seed: %d" % Globals.rng.seed

