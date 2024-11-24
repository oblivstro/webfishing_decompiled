extends HBoxContainer

var held_data = []

func _setup(data):
	held_data = data
	$RichTextLabel.text = str(data["steam_name"])
	
	var ping = 0
	if Network.PING_DICTIONARY.keys().has(data["steam_id"]):
		ping = Network.PING_DICTIONARY[data["steam_id"]]
	$ping.text = "ping: " + str(ping)
	
	if data["steam_id"] == Network.KNOWN_GAME_MASTER: $RichTextLabel.text = "[host] " + $RichTextLabel.text
	
	$mute.icon = preload("res://Assets/Textures/UI/player_options2.png") if PlayerData.players_muted.has(data["steam_id"]) else preload("res://Assets/Textures/UI/player_options1.png")
	$block.icon = preload("res://Assets/Textures/UI/player_options4.png") if PlayerData.players_hidden.has(data["steam_id"]) else preload("res://Assets/Textures/UI/player_options3.png")
	
	$mute.disabled = data["steam_id"] == Network.STEAM_ID
	$block.disabled = data["steam_id"] == Network.STEAM_ID
	
	
	$ban.disabled = not Network.GAME_MASTER or data["steam_id"] == Network.STEAM_ID

func _on_mute_pressed(): PlayerData._mute_player(held_data["steam_id"])
func _on_block_pressed(): PlayerData._hide_player(held_data["steam_id"])
func _on_ban_pressed(): if Network.GAME_MASTER: Network._ban_player(held_data["steam_id"])

func _on_steam_pressed():
	if Network.STEAM_ENABLED: Steam.activateGameOverlayToUser("steamid", held_data["steam_id"])
