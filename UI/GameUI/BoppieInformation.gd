extends VBoxContainer

var boppie = null
onready var show_dna = false
var opened = false
onready var left_side_panel = get_parent().get_parent().get_parent()

onready var neurons = get_node("TabContainer/Neural network/Neurons")
onready var dna = $TabContainer/DNA/DNA

func _ready():
	left_side_panel.visible = false
	#left_side_panel.rect_position = Vector2(-170, 0)
	var game_controllers = get_tree().get_nodes_in_group("GameController")
	for game_controller in game_controllers:
		game_controller.connect("BoppieControlChanged", self, "_on_BoppieControlChanged")
		
func _on_BoppieControlChanged(controlled_boppie):
	
	var different_boppie = (boppie != controlled_boppie)
	self.boppie = controlled_boppie
	# left_side_panel.visible = (boppie != null)
	var should_open = boppie != null
	#left_side_panel.visible = should_open
	left_side_panel.visible = true
	if opened != should_open:
		opened = should_open
		var other = Vector2(-left_side_panel.rect_size.x, 0)
		var start = other if opened else Vector2.ZERO
		var end = Vector2.ZERO if opened else other
		$Tween.interpolate_property(
			left_side_panel, "rect_position", start, end, .6, 
			Tween.TRANS_ELASTIC, Tween.EASE_OUT
		)
		$Tween.start()
	if should_open:
		neurons.neural_network = boppie.ai
		if different_boppie:
			_on_Show_toggled(true)
	else:
		neurons.neural_network = null
		
	
func _process(_delta):
	if boppie == null:
		return
	$BoppieName.text = "Boppie"
	$Energy.text = "Energy: %.1f/%.1f" % [abs(boppie.energy), boppie.max_energy]
	$OffspringEnergy.text = "Offspring energy: %.1f/%.1f" % [
		fmod(boppie.offspring_energy, boppie.required_offspring_energy), 
		boppie.required_offspring_energy,
	]
	$OffspringCount.text = "Offspring count: %d" % boppie.offspring_count
	$Level.text = "Level: %d (size: %.1f)" % [boppie.level, boppie.scale.x]
	$Survived.text = "Spawned: %s (%.1f s)" % [
		Globals.formatted_time(int(boppie.spawn_time)), 
		Globals.elapsed_time - boppie.spawn_time
	]
	$Eaten.text = "Eaten: %d" % boppie.times_eaten
	

func _on_Show_toggled(button_pressed=true):
	show_dna = $TabContainer/DNA/HBoxContainer/ShowDNA.pressed
	dna.text = ("%s" % boppie.get_dna_str()) if show_dna else "{ ... }"
	

func _on_CopyDNA_pressed():
	if boppie != null:
		Globals.dna_clipboard = boppie.dna.duplicate(true)


func _on_PasteDNA_pressed():
	if boppie != null and Globals.dna_clipboard != null:
		boppie.set_dna(Globals.dna_clipboard)
		_on_Show_toggled()


func _on_DNA_gui_input(event):
	if event.is_action_pressed("ui_cancel"):
		dna.release_focus()


func _on_ApplyDNA_pressed():
	boppie.set_dna_str(dna.text)
