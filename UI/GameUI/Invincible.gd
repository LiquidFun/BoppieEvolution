extends CheckBox

onready var game_controller = get_tree().get_nodes_in_group("GameController")[0]

# In order to avoid the "pressed =" assignment making a callback
# use this state variable to avoid it. 
var no_pressed_callback = false

func _on_BoppieInvincibilityChanged(new_boppie, is_invincible):
	no_pressed_callback = true
	pressed = is_invincible
	no_pressed_callback = false

func _ready():
	game_controller.connect("BoppieInvincibilityChanged", self, "_on_BoppieInvincibilityChanged")


func _on_Invincible_toggled(button_pressed: bool) -> void:
	if not no_pressed_callback:
		no_pressed_callback = true
		game_controller.toggle_controlled_boppie_invincibility(!button_pressed)
	no_pressed_callback = false
