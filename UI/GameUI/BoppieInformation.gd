extends VBoxContainer

var boppie = null
var show_dna = false
var opened = false
onready var left_side_panel = get_parent().get_parent().get_parent()

func _ready():
	left_side_panel.visible = false
	#left_side_panel.rect_position = Vector2(-170, 0)
	var game_controllers = get_tree().get_nodes_in_group("GameController")
	for game_controller in game_controllers:
		game_controller.connect("BoppieControlChanged", self, "_on_BoppieControlChanged")
		
func _on_BoppieControlChanged(controlled_boppie):
	self.boppie = controlled_boppie
	left_side_panel.visible = true
	# left_side_panel.visible = (boppie != null)
	var should_open = boppie != null
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
		$Neurons.neural_network = boppie.ai
		
	
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
	$Survived.text = "Survived: %.1f" % (Globals.elapsed_time - boppie.spawn_time)
	$Eaten.text = "Eaten: %d" % boppie.times_eaten
	$DNA.text = ("%s" % boppie.get_dna_str()) if show_dna else "{ ... }"


func _on_Show_toggled(button_pressed):
	show_dna = !show_dna
	

func _on_CopyDNA_pressed():
	if boppie != null:
		Globals.dna_clipboard = boppie.dna.duplicate(true)


func _on_PasteDNA_pressed():
	if boppie != null and Globals.dna_clipboard != null:
		boppie.set_dna(Globals.dna_clipboard)
