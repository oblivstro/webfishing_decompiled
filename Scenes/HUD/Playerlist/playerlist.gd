extends Control

onready var grid = $ScrollContainer / GridContainer

onready var entry = preload("res://Scenes/HUD/Playerlist/player_entry.tscn")

func _ready():
	Network.connect("_members_updated", self, "_refresh_list")
	PlayerData.connect("_mute_update", self, "_refresh_list")
	_refresh_list()

func _refresh_list():
	for child in grid.get_children():
		child.queue_free()
	
	for player in Network.LOBBY_MEMBERS:
		var e = entry.instance()
		grid.add_child(e)
		e._setup(player)
	
	$Label2.visible = Network.LOBBY_MEMBERS.size() <= 0
	
	var text = ""
	if not Network.PLAYING_OFFLINE:
		var display = Steam.getLobbyData(Network.STEAM_LOBBY_ID, "name")
		var display_custom = Steam.getLobbyData(Network.STEAM_LOBBY_ID, "lobby_name")
		var age_limit = Steam.getLobbyData(Network.STEAM_LOBBY_ID, "age_limit")
		
		if age_limit == "true": text = "(18+) "
		if display_custom != "": text = text + " " + str(display_custom)
		else: text = text + "" + str(display) + "'s Lobby"
		
		text = text + "\n" + str(Network.LOBBY_MEMBERS.size()) + " / " + str(Steam.getLobbyData(Network.STEAM_LOBBY_ID, "cap")) + " Player(s): "
	else:
		text = "Offline Game"
	
	$Label.text = text
