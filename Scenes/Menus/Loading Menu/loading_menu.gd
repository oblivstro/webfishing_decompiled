extends Control

var t = 0
var waiting = false

func _on_Timer_timeout():
	t += 1
	if t >= 4: t = 0
	$CenterContainer / Label.text = "loading"
	for i in t: $CenterContainer / Label.text = $CenterContainer / Label.text + "."
	
	if waiting:
		var packets_recieved = 0
		for key in Network.FLUSH_PACKET_INFORMATION.keys():
			if Network.FLUSH_PACKET_INFORMATION[key] > 0:
				packets_recieved += 1
		
		if packets_recieved >= 6 or packets_recieved >= (Network.LOBBY_MEMBERS.size() - 1):
			_join_world()

func _ready():
	if Network.PLAYING_OFFLINE or Network.LOBBY_MEMBERS.size() <= 1:
		yield (get_tree().create_timer(1.0), "timeout")
		_join_world()
	else:
		waiting = true

func _join_world():
	waiting = false
	SceneTransition._change_scene("res://Scenes/World/world.tscn", 0.3, false, true)
