extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	container = $Panel/ScrollContainer/VBoxContainer
	pass # Replace with function body.


var playerInfoLinePath = preload("res://scenes/player_info_line.tscn")
var container : Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	
	
	while !fixNumber():
		pass
	
	var keys = Globals.playerScores.keys()
	var children = container.get_children()
	
	for i in keys.size():
		children[i].setLine(keys[i],Globals.playerScores[keys[i]][0],Globals.playerScores[keys[i]][1],Globals.playerScores[keys[i]][2],Globals.playerScores[keys[i]][3])
	
	#setLine(playerName,wins,kills,deaths,roundsPlayed):
	
	pass
	

func fixNumber():
	
	if Globals.playerScores.keys().size() > container.get_children().size():
		var newLine = playerInfoLinePath.instantiate()
		container.add_child(newLine)
		return false
	elif Globals.playerScores.keys().size() < container.get_children().size():
		var child = container.get_child(0)
		container.remove_child(child)
		child.queue_free()
		return false
	else:
		return true
	
	
