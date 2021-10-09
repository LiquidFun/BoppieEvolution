extends CanvasLayer

var is_saving := true

func show(save_mode):
	if save_mode:
		$SaveDialog.mode = FileDialog.MODE_SAVE_FILE
	else:
		$SaveDialog.mode = FileDialog.MODE_OPEN_FILE
	var directory = Directory.new()
	directory.make_dir("user://saves")
	$SaveDialog.popup_centered()
	$SaveDialog.current_file = Utils.iso_datetime() + ".tscn"
	$SaveDialog.current_path = Utils.iso_datetime() + ".tscn"


func _on_SaveDialog_file_selected(path):
	if $SaveDialog.mode == FileDialog.MODE_SAVE_FILE:
		var file = File.new()
		file.open(path, File.WRITE)
		for game_controller in get_tree().get_nodes_in_group("GameController"):
			file.store_string(var2str(game_controller))
		file.close()
		#var packed_scene = PackedScene.new()
		#packed_scene.pack(get_tree().get_current_scene())
		#ResourceSaver.save(path, packed_scene)
	else:
		var packed_simulation = load(path)
		var simulation = packed_simulation.instance()
		get_tree().change_scene_to(simulation)
