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
	
func get_best_fitness(group, count=1):
	var fitness = []
	for boppie in get_tree().get_nodes_in_group(group):
		fitness.append(boppie.fitness())
	fitness.sort()
	var bestn_average = 0
	count = min(len(fitness), count)
	if count == 0:
		return 0
	for i in range(count):
		bestn_average += fitness[len(fitness) - i - 1]
	return bestn_average / count
	
func replot():
	for group in ["Owlie", "Kloppie"]:
		add_point(group + "s", get_best_fitness(group, 3))
	update()
