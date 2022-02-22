extends Node

enum NNInput {ENERGY, RAY_DIST, RAY_TYPE, EATS, DANGER_SENSE}
enum Raytype {NONE, OWLIE, KLOPPIE, FOOD}
enum Sense {
	BIAS = 1 << 0,
	VISION_RAY_EATS = 1 << 1,
	DANGER_SENSE = 1 << 2,
	MEMORY = 1 << 3,
	TIMER = 1 << 4,
	HUNGER = 1 << 5,
	THIRST = 1 << 6,
	WATER_RAY = 1 << 7,
	GROUND = 1 << 8,
	ALLY_SENSE = 1 << 9,
}

class Generation:
	extends Reference
	var i = 1
	func mutate(_property, _mutability):
		i += 1
	func crossover(_property, other_i):
		i = max(i, other_i)
	func _to_string() -> String:
		return "[Generation]"

		
class Senses:
	extends Reference
	var bitmask = 0
	
	func _init(bitmask=0):
		self.bitmask |= bitmask
		
	func mutate(_property, _mutability):
		pass
		
	func crossover(_property, other_bitmask):
		bitmask |= other_bitmask
	func _to_string() -> String:
		return "[Senses]"
		
class Coloration:
	extends Reference
	var energy_gradient = Gradient.new()
	var hue setget set_hue
	
	func _init():
		self.hue = Globals.rng.randf()
		#energy_gradient.add_point(.5, Color.white)
	
	func mutate(_property, mutability):
		hue += (Globals.rng.randf() * 2 - 1) * mutability / 4.0
		self.hue = fmod(hue + 1.0, 1.0)
		
	func crossover(_property, other_hue):
		var new_hue = 0
		var best_diff = 100
		if abs(hue - other_hue) < 0.5:
			self.hue = (hue + other_hue) / 2.0
		else:
			self.hue = fmod((hue + other_hue + 1) / 2.0, 1.0)
		
	func set_hue(new_hue):
		hue = new_hue
		energy_gradient.set_color(0, Color.from_hsv(hue, 0, .5))
		#energy_gradient.set_color(1, Color.from_hsv(hue, 1, 1).darkened(.2))
		energy_gradient.set_color(1, Color.from_hsv(hue, 1, 1))
		
	func _to_string() -> String:
		return "[Coloration]"
		
class NeuronTimer:
	extends Timer
	func _init():
		wait_time = 5
	func _ready() -> void:
		self.start()
	func neuron_value():
		return (wait_time - time_left) / wait_time
	func mutate(_property, mutability):
		self.wait_time += mutability * (Globals.rng.randf() * 10)
	func crossover(_property, other_seconds):
		self.wait_time = [wait_time, other_seconds][Globals.rng.randi() % 2]
	func _to_string() -> String:
		return "[NeuronTimer]"

