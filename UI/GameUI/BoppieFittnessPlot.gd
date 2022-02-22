extends TimePlot


onready var game_controller = get_tree().get_nodes_in_group("GameController")[0]

func _ready() -> void:
	add_dataset("Owlies", Color.green, true)
	add_dataset("Kloppies", Color.blue, true)
	
class DataStatistics:
	# Careful about using classes like this, as these are orphaned after use
	var variance = 0
	var stderr = 0
	var mean = 0
	var sum = 0
	func _init(boppies: Array):
		for boppie in boppies:
			sum += boppie.fitness()
		if len(boppies) != 0:
			mean = sum / len(boppies)
			for boppie in boppies:
				variance += pow(boppie.fitness() - mean, 2)
			variance /= len(boppies)
			stderr = sqrt(variance)
			
	
func get_average_fitness(group):
	var boppies = get_tree().get_nodes_in_group(group)
	# return DataStatistics.new(boppies)
	var mean = 0
	var sum = 0
	for boppie in boppies:
		sum += boppie.fitness()
	if len(boppies) != 0:
		mean = sum / len(boppies)
	return mean
	
	
func replot():
	for group in ["Owlie", "Kloppie"]:
		add_point(group + "s", get_average_fitness(group))
	update()
