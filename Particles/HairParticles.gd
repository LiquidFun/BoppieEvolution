extends Node2D

export var strains = 10

func _ready():
	for i in range(strains):
		add_child($Strain.duplicate())
