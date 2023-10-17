extends Node

#multiplayer stuff
var peer 
var is_server = false
var multiplayerId = 1
var nameTag = ""
var internalAddress
var commandLineOpen

var world

var player
var avatar

var resetting = false

#player UI

var playerHealth = 100
var maxPlayerHealth = 100
var playerDashes = 3
var ammo
var timeTillNextShot = 0
var maxTimeTillNextShot = 0
var playerIsDead = false

var lastRoundStart = 0

var gunTracking : Dictionary = {}
