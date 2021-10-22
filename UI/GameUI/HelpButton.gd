extends Button


func _unhandled_key_input(event):
	if event.is_action_pressed("show_help_popup"):
		self.pressed = not self.pressed


func _on_HelpButton_toggled(button_pressed):
	if button_pressed:
		$HelpPopup.popup_centered()
		var label = $HelpPopup/MarginContainer/Keybindings
		var help_text = "[center]Keybindings[/center]\n\n"
		for action in InputMap.get_actions():
			if action.begins_with("ui_"):
				continue
			var keys = PoolStringArray()
			for key in InputMap.get_action_list(action):
				if key is InputEventMouseButton:
					if key.button_index == BUTTON_WHEEL_DOWN:
						keys.append("Mouse wheel down")
					elif key.button_index == BUTTON_WHEEL_UP:
						keys.append("Mouse wheel up")
				else:
					keys.append("%s" % key.as_text())
			help_text += "• %s:\t\t %s\n" % [keys.join(", "), action.replace("_", " ").capitalize()]
		# help_text += "[/list]"
		label.bbcode_text = help_text
	else:
		$HelpPopup.hide()
