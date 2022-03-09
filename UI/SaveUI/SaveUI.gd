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
	
func recursive_set_owner(curr):
	for child in curr.get_children():
		print(str(curr) + " -> " + str(child) + " from " + str(child.get_owner()))
		child.owner = get_tree().get_root()
		recursive_set_owner(child)
		
func recursive_save(curr_node, data_list):
	data_list.append(curr_node)
	for child in curr_node.get_children():
		data_list.append([])
		recursive_save(child, data_list[-1])
		
func recursive_load(curr_node, data_list):
	data_list.append(var2str(curr_node))
	for child in curr_node.get_children():
		data_list.append([])
		recursive_load(child, data_list[-1])

func _on_SaveDialog_file_selected(path):
	var file = File.new()
	# get_tree().paused = true
	if $SaveDialog.mode == FileDialog.MODE_SAVE_FILE:
		recursive_set_owner(get_tree().get_root())
		var save_data = []
		#recursive_save(get_tree().get_root(), save_data)
		
		#file.open(path, File.WRITE)
		#file.store_var(save_data)
		#file.store_string(var2str(save_data))
		#for game_controller in get_tree().get_nodes_in_group("GameController"):
		#	file.store_string(var2str(game_controller))
		#file.close()
		var packed_scene = PackedScene.new()
		packed_scene.pack(get_tree().get_root())
		ResourceSaver.save(path, packed_scene)
	else:
		# var node = Node2D.new()
		# get_tree().change_scene_to(node)
		#file.open(path, File.READ)
		#var load_data = file.get_var()
		#for game_controller in get_tree().get_nodes_in_group("GameController"):
		#	file.store_string(var2str(game_controller))
		#var load_data = str2var(file.get_as_text())
		#file.close()
		#print(load_data)
		var packed_simulation = load(path)
		# get_tree().get_current_scene().queue_free()
		# var simulation = packed_simulation.instance()
		get_tree().change_scene_to(packed_simulation)
		# get_tree().get_root().replace_by(simulation)
	# yield get_tree().change
	# get_tree().paused = false
