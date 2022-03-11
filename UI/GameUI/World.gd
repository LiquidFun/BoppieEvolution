extends Label

func _ready() -> void:
	hint_tooltip = "Seed: %s (note that the same seed does not guarantee the same simulation, because the timesteps taken might be different, creating different scenarios)" % Globals.rng.seed
