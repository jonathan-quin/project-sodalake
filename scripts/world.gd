extends Node2D

var peer 
@export var avatar_scene : PackedScene
@onready var cam = $Camera2D
var port = 8910

# Called when the node enters the scene tree for the first time.
func _ready():
	
	multiplayer.connected_to_server.connect(connectedToServer)
	multiplayer.connection_failed.connect(failedToConnect)
	pass # Replace with function body.

func connectedToServer():
	print("connected!")
func failedToConnect():
	print("failed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var temp = ""
	
	temp += str(multiplayer.get_default_interface()) + "\n"
	
	temp += str(multiplayer.get_peers()) + "\n"
	
	#$Label.text = temp
	
	
	pass


func _on_host_button_pressed():
	peer = ENetMultiplayerPeer.new()
	
	var error = peer.create_server(port,4)
	
	print(error)
	
	multiplayer.set_multiplayer_peer(peer)
	multiplayer.peer_connected.connect(add_avatar)
	add_avatar()
	cam.enabled = false
	
	print("waiting for players!")
	
	pass # Replace with function body.


func _on_client_button_pressed():
	peer = ENetMultiplayerPeer.new()
	
	var err = peer.create_client(IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1),port)
	multiplayer.multiplayer_peer = peer
	cam.enabled = false
	
	print(err)
	
	pass # Replace with function body.


func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func add_avatar(id = 1):
	var avatar = avatar_scene.instantiate()
	avatar.name = str(id)
	$worldObjectHolder.call_deferred("add_child",avatar)
	


var bulletPath = preload("res://bullet.tscn")
func createBullet(pos,velocity,type):
	rpc("_createBullet",pos,velocity)
@rpc("any_peer", "call_local") func _createBullet(pos,velocity,type):
	
	var bullet = bulletPath.instantiate()
	bullet.position = pos
	bullet.translate = velocity
	
	#get_tree().get_first_node_in_group("objectHolder").add_child(bullet,true)
	$worldObjectHolder.call_deferred("add_child",bullet,true)
	



func del_player(id):
	rpc("_del_player",id)
@rpc("any_peer", "call_local") func _del_player(id):
	get_node(str(id)).queue_free()
