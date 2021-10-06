extends Node


var current_food_count = 0
var draw_vision_rays = true
var performance_mode = false
var boppies_died = 0
var boppies_born = 0
var boppies_spawned = 0

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

