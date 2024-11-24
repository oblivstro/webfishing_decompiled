extends Control

signal _pressed

func _setup(lobby_default_name, lobby_name, player_count, player_limit, age_limit, dated, banned):
	var display_name = lobby_default_name
	if lobby_name != "":
		display_name = lobby_name
		if OptionsMenu.chat_filter: display_name = SwearFilter._filter_string(str(lobby_name))
	
	else: display_name = str(display_name) + "'s Lobby"
	
	display_name = display_name.replace("[", "")
	display_name = display_name.replace("]", "")
	
	var cap = str(player_limit)
	if cap == "": cap = str(12)
	
	if age_limit: display_name = "[color=#ff0031](18+)[/color] " + display_name
	if dated: display_name = "[color=#6a4420](VERSION MISMATCH)[/color] " + display_name
	if banned: display_name = "[color=#6a4420](BANNED)[/color] " + display_name
	
	$Panel / HBoxContainer / Label.bbcode_text = display_name + " [color=#b48141](" + str(player_count) + "/" + cap + ")[/color]"
	$Panel / HBoxContainer / Button.disabled = player_count >= int(cap) or dated or banned

func _on_Button_pressed():
	emit_signal("_pressed")
