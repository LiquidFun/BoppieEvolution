extends CheckBox

onready var game_controller = get_tree().get_nodes_in_group("GameController")[0]

func _on_BoppieInvincibilityChanged(new_boppie, is_invincible):
	pressed = is_invincible

func _ready():
	game_controller.connect("BoppieInvincibilityChanged", self, "_on_BoppieInvincibilityChanged")


func _on_Invincible_toggled(button_pressed: bool) -> void:
	game_controller.toggle_controlled_boppie_invincibility()
