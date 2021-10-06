extends Node


var current_food_count = 0
var draw_vision_rays = false
var performance_mode = false
var boppies_died = 0
var boppies_born = 0
var boppies_spawned = 0
var nn_thread: Thread = Thread.new()

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

signal HalfSecondTimer
var last_emit_time = 0

func _process(_delta):
	if last_emit_time + 500 < OS.get_ticks_msec():
		last_emit_time = OS.get_ticks_msec()
		emit_signal("HalfSecondTimer")
		
