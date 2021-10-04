extends Node2D

export(NodePath) var boppie = null

func _process(delta):
	if boppie:
		boppie.move(randf(), delta)
		boppie.turn(randf(), delta)
