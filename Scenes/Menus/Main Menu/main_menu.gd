extends Control

var hovered_button = null
var disabled = false
var refreshing = false
var lobby_search_time = 0
var server_age_limit = false

onready var code = $lobby_browser / Panel / Panel3 / HBoxContainer / serv_options
onready var dial = $lobby_browser / Panel / Panel2 / TextureRect / Control / dial

func _ready():
	Network.set_rich_presence("#menu")
	Network.connect("_webfishing_lobbies_returned", self, "_lobby_list_returned")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$HBoxContainer / Label.text = "lamedeveloper v" + str(Globals.GAME_VERSION)
	
	for child in $VBoxContainer.get_children():
		if child is Button:
			child.connect("mouse_entered", self, "_hover_button", [child])
			child.connect("mouse_exited", self, "_exit_button", [child])
			child.add_to_group("menu_button")
	
	$"%serv_options".add_item("Public")
	$"%serv_options".add_item("Code-Only")
	$"%serv_options".add_item("Friends-Only")
	$"%serv_options".add_item("Offline/Solo")
	
	for i in 12: $"%max_players".add_item(str(i + 1))
	$"%max_players".selected = 11
	
	$"%lobbyname".placeholder_text = str(Network.STEAM_USERNAME) + "'s Lobby"
	
	_close_browser()
	
	yield (get_tree().create_timer(1.0), "timeout")
	print("NETWORK PROPMPT: ", Network.JOIN_ID_PROMPT)
	if Network.JOIN_ID_PROMPT != - 1:
		if UserSave.current_loaded_slot == - 1:
			Network.JOIN_ID_PROMPT = - 1
			return 
		
		_disable_buttons()
		Network._connect_to_lobby(Network.JOIN_ID_PROMPT)
		Network.JOIN_ID_PROMPT = - 1

func _process(delta):
	$TextureRect.margin_top = sin(OS.get_ticks_msec() * 0.001) * 8
	$TextureRect.margin_bottom = sin(OS.get_ticks_msec() * 0.001) * 8
	
	$lobby_browser / Panel / Button2.disabled = disabled or refreshing
	
	
	
	for node in get_tree().get_nodes_in_group("menu_button"):
		node.size_flags_stretch_ratio = lerp(node.size_flags_stretch_ratio, 0.5 if hovered_button != node else 1.0, 0.1)

func _physics_process(delta):
	dial.rotation_degrees += 6.0





func _on_quit_pressed(): Globals._close_game()
func _on_reset_pressed(): PlayerData._reset_save()

func _disable_buttons():
	disabled = true
	$VBoxContainer / play.disabled = true
	$VBoxContainer / settings.disabled = true
	$VBoxContainer / quit.disabled = true
	
	$lobby_browser / Panel / Panel / Button.disabled = true
	$lobby_browser / Panel / Panel3 / HBoxContainer / Button.disabled = true

func _hover_button(node):
	hovered_button = node
func _exit_button(node):
	hovered_button = null

func _on_settings_pressed():
	OptionsMenu._open()




func _open_browser():
	$lobby_browser.visible = true
	_refresh_lobbies()
func _close_browser(): $lobby_browser.visible = false

func _refresh_lobbies():
	var lob = $lobby_browser / Panel / Panel2 / ScrollContainer / VBoxContainer
	for child in lob.get_children(): child.queue_free()
	
	yield (get_tree().create_timer(0.2), "timeout")
	print("Requesting a lobby list")
	
	dial.show()
	refreshing = true
	lobby_search_time = 0
	
	var ver_match = $"%versionmatch".pressed
	var age_match = $"%agematch".pressed
	var full_match = $"%fullmatch".pressed
	
	Network._find_all_webfishing_lobbies(ver_match, age_match, full_match)

func _lobby_list_returned(lobbies):
	if not refreshing: return 
	
	var lob = $lobby_browser / Panel / Panel2 / ScrollContainer / VBoxContainer
	var valid_lobbies = 0
	
	print(lobbies.size(), " found.")
	dial.hide()
	refreshing = false
	
	var created_lobbies = []
	
	for lobby in lobbies:
		if created_lobbies.has(lobby): return 
		created_lobbies.append(lobby)
		
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var lobby_custom_name = Steam.getLobbyData(lobby, "lobby_name")
		var lobby_num_members = Steam.getNumLobbyMembers(lobby)
		var lobby_cap = Steam.getLobbyData(lobby, "cap")
		var lobb_version = Steam.getLobbyData(lobby, "version")
		var lobb_type = Steam.getLobbyData(lobby, "type")
		
		if lobb_type != "public": continue
		
		var dated = str(lobb_version) != str(Globals.GAME_VERSION)
		var lobby_age = true if Steam.getLobbyData(lobby, "age_limit") == "true" else false
		
		var banned = false
		var blocked_players = Steam.getLobbyData(lobby, "banned_players")
		var split = blocked_players.split(",")
		for i in split:
			if int(i) == Network.STEAM_ID:
				banned = true
		
		valid_lobbies += 1
		
		if $"%hidenames".pressed: lobby_custom_name = ""
		
		var lb = preload("res://Scenes/Menus/Main Menu/ServerButton/server_button.tscn").instance()
		lb._setup(lobby_name, lobby_custom_name, lobby_num_members, lobby_cap, lobby_age, dated, banned)
		lob.add_child(lb)
		lb.connect("_pressed", self, "_join_lobby", [lobby])
	
	if valid_lobbies <= 0:
		var lbl = Label.new()
		lbl.text = "No Servers Found :("
		lob.add_child(lbl)

func _start_lobby():
	var tags = []
	if server_age_limit: tags.append("18+")
	
	var cap = $"%max_players".selected + 1
	var display_name = $"%lobbyname".text
	
	Network._create_custom_lobby($"%serv_options".selected, cap, tags, display_name)
	_disable_buttons()

func _join_lobby(id):
	if disabled: return 
	Network._connect_to_lobby(id)
	_disable_buttons()

func _join_from_code():
	Network.PLAYING_OFFLINE = false
	Network._search_for_lobby(code.text)
	code.clear()
	_disable_buttons()

func _on_Timer_timeout():
	if refreshing:
		lobby_search_time += 1
		if lobby_search_time > 20:
			lobby_search_time = 0
			_lobby_list_returned([])


func _on_18_tag_pressed():
	server_age_limit = not server_age_limit
	$"%18_tag".text = "ENABLED" if server_age_limit else "DISABLED"
