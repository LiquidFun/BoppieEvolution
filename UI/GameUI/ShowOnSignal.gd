extends Label

export var hide_instead = true
export var signal_name = "BoppieInvincibilityChanged"

onready var game_controller = get_tree().get_nodes_in_group("GameController")[0]

func _on_SignalFired(arg1=null, arg2=null, arg3=null):
	self.visible = false if arg2 == null else arg2

func _ready():
	game_controller.connect(signal_name, self, "_on_SignalFired")
	self.visible = !hide_instead
	
