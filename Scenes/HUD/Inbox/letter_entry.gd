extends Control

signal _accepted
signal _deleted

var delete_ticked = false

func _setup(data, inbound):
	$Label.text = str(data["header"]) + " from " + str(data["user"])
	if data.items.size() > 0:
		var plural = "" if data.items.size() <= 1 else "s"
		$Label.text = $Label.text + " (" + str(data.items.size()) + " gift" + plural + ")"

func _on_Button_pressed():
	emit_signal("_accepted")

func _on_Button2_pressed():
	if not delete_ticked:
		$HBoxContainer / Button2.text = "Are you sure?"
		delete_ticked = true
	else:
		emit_signal("_deleted")
