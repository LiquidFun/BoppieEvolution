extends Node


var current_food_count := 0
var draw_senses := false
var draw_current_senses := false
var boppies_died := 0
var boppies_born := 0
var boppies_spawned := 0
# var nn_thread: Thread = Thread.new()
var elapsed_time := 0.0
var dna_clipboard = null
var kloppies_cannibals = false
var use_random_seed = true
onready var simulation_real_start_time = OS.get_datetime()
onready var simulation_unix_start_time = OS.get_unix_time()


var rng = RandomNumberGenerator.new()

func _ready():
	if use_random_seed:
		rng.randomize()
	else:
		var random_seed = 0xface
		rng.seed = random_seed
	
	
signal PerformanceModeChanged(value)
var performance_mode = true setget set_performance_mode
func set_performance_mode(new_value):
	if performance_mode != new_value:
		performance_mode = new_value
		emit_signal("PerformanceModeChanged", new_value)


signal HalfSecondTimer
var last_emit_time = 0

func _process(delta):
	elapsed_time += delta
	if last_emit_time + 500 < OS.get_ticks_msec():
		last_emit_time = OS.get_ticks_msec()
		emit_signal("HalfSecondTimer")
		print_stray_nodes()

func formatted_time(seconds = null):
	if seconds == null:
		seconds = int(elapsed_time)
	if seconds is Dictionary:
		seconds = 3600 * seconds["hour"] + 60 * seconds["minute"] + seconds["second"]
	return "%02d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60]
	
func formatted_date(date: Dictionary):
	if date == null:
		date = OS.get_date()
	return "%04d-%02d-%02d" % [date["year"], date["month"], date["day"]]

func formatted_real_time_passed():
	return formatted_time(OS.get_unix_time() - simulation_unix_start_time)
	
func formatted_real_start_datetime():
	return formatted_date(simulation_real_start_time) + " " + formatted_time(simulation_real_start_time)
	
signal DifficultyChanged(new_value)
var difficulty = .3 setget set_difficulty

func set_difficulty(new_value):
	difficulty = new_value
	emit_signal("DifficultyChanged", difficulty)

var saved_collision_layer_mask = {}

func activate(node):
	var collision_layer_mask = saved_collision_layer_mask[node]
	saved_collision_layer_mask.erase(node)
	node.collision_layer = collision_layer_mask[0]
	node.collision_mask = collision_layer_mask[1]
	node.set_process(true)
	node.set_physics_process(true)
	
func deactivate(node):
	saved_collision_layer_mask[node] = [node.collision_layer, node.collision_mask]
	node.collision_layer = 0
	node.collision_mask = 0
	node.set_process(false)
	node.set_physics_process(false)
