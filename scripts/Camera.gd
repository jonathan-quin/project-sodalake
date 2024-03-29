extends Node2D


var deadZone = 10

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	
	$allUi/address.text = Globals.internalAddress
	$allUi/CheckBox.visible = Globals.is_server
	
	Globals.playerCamera = self
	pass


func _process(delta):
	
	
	
	$allUi/Health.value = Globals.playerHealth
	$allUi/Health.max_value = Globals.maxPlayerHealth
	
	$allUi/dashCount.value = Globals.dashRechargePercet
	$allUi/dashCount.max_value = 1
	
	$allUi/dashCool.value = 1-Globals.dashCool
	$allUi/dashCool.max_value = 1
	
	$allUi/bulletIndicator.text = "Bullets left: " + str(Globals.ammo)
	$allUi/bulletIndicator.visible = Globals.player.holdingWeapon
	
	$allUi/reload.value = Globals.maxTimeTillNextShot-Globals.timeTillNextShot
	$allUi/reload.max_value = Globals.maxTimeTillNextShot
	$allUi/reload.visible = Globals.player.holdingWeapon
	
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("shoot"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	
	$allUi/Health.visible = !Globals.playerIsDead
	$allUi/dashCount.visible = !Globals.playerIsDead
	$allUi/dashCool.visible = !Globals.playerIsDead
	$allUi/DashCount.visible = !Globals.playerIsDead
	
	if Globals.playerIsDead:
		$Camera2D.zoom = lerp($Camera2D.zoom,Vector2(0.7,0.7),1 * delta)
	else:
		$Camera2D.zoom = lerp($Camera2D.zoom,Vector2(1.2,1.2),1 * delta)
	
	if Globals.playerIsDead and Globals.timeLastDied + 800 < Time.get_ticks_msec():
		var targetVelocity = Vector2()
		if Input.is_action_pressed("right"):
			targetVelocity.x += 1
		if Input.is_action_pressed("left"):
			targetVelocity.x -= 1
		if Input.is_action_pressed("down"):
			targetVelocity.y += 1
		if Input.is_action_pressed("up"):
			targetVelocity.y -= 1
		
		position += targetVelocity * 20
	
	if Globals.resetting:
		position = lerp(position,Vector2.ZERO,2 * delta)
		
	
	if Time.get_ticks_msec() > timeToCloseCommandLine and !Globals.commandLineOpen:
		$allUi/commandLineLabel.visible = false
	
	
	
	if Input.is_action_pressed("tab") or  Globals.paused:
		if winTween:
			winTween.kill()
		$allUi/ScoreBoard.modulate = Color(1,1,1,1)
		$allUi/winIndicator.modulate = Color(1,1,1,0)
	elif !Globals.resetting:
		$allUi/ScoreBoard.modulate = Color(1,1,1,0)
		$allUi/winIndicator.modulate = Color(1,1,1,0)
	


func shake(duration, strength):
	$Camera2D.set_trauma(duration,strength)


var timeToCloseCommandLine = 0

func _input(event : InputEvent) -> void:
	
	
	
	if event is InputEventMouseMotion:
		
		if Globals.playerIsDead || Globals.paused || Globals.resetting:
			return
		
		var _target = event.position - get_viewport().size * 0.5
		
		_target = get_global_mouse_position() - global_position
		
		
		
		if _target.length() < deadZone:
			position = Vector2(0,0)
		else:
			position = _target.normalized() * (min(600,_target.length()) - deadZone) * 0.5
	
	if event.is_action_pressed("commandLine") and Globals.is_server:
		$allUi/commandLine.visible = true
		$allUi/commandLineLabel.visible = true
		Globals.commandLineOpen = true
		$allUi/commandLine.grab_focus()
	if event.is_action_pressed("enter"):
		if Globals.commandLineOpen:
			Globals.commandLineOpen = false
			$allUi/commandLine.visible = false
			$allUi/commandLine.release_focus()
			$allUi/commandLineLabel.text += takeCommand($allUi/commandLine.text) + "\n"
			$allUi/commandLineLabel.text = trimCommandLineLabel($allUi/commandLineLabel.text,30)
			$allUi/commandLine.text = ""
			
			timeToCloseCommandLine = Time.get_ticks_msec() + 3000
			
	
	


func _on_check_box_toggled(button_pressed):
	$allUi/address.visible = button_pressed
	pass # Replace with function body.

#commands!
func trimCommandLineLabel(input_string,lineMax):
	
	# Count the number of newline characters in the input string
	var newline_count = input_string.count("\n")
	
	if newline_count > lineMax:
		# Find the position of the first newline character
		for i in newline_count - lineMax:
			var first_newline_position = input_string.find("\n")
			# Extract everything after the first newline character
			input_string = input_string.substr(first_newline_position + 1)
	return input_string

func takeCommand(command : String):
	if command.substr(0,5) == "/give":
		return giveCommand(command.substr(5).replacen(" ",""))
	
	if command.substr(0,5) == "/guns":
		return listGuns()
	
	
	
	if command.substr(0,10) == "/maxHealth":
		return maxHealthCommand(command.substr(10).replacen(" ",""))
	
	if command.substr(0,8) == "/players":
		return listPlayers()
	
	if command.substr(0,9) == "/shutdown":
		return shutDownCommand(command.substr(9).replacen(" ",""))
	
	if command.substr(0,5) == "/kill":
		return killCommand(command.substr(5).replacen(" ",""))
	
	if command.substr(0,5) == "/kick":
		return kickCommand(command.substr(5).replacen(" ",""))
	
	if command.substr(0,12) == "/resetScores":
		return resetScoresCommand()
	
	if command.substr(0,6) == "/reset":
		return resetCommand()
	
	if command.substr(0,16) == "/setGunSpawnRate":
		return maxGunSpawnRatesCommand(command.substr(16).replacen(" ",""))
	
	if command.substr(0,13) == "/setStartGuns":
		return gunSpawnsAtStartCommand(command.substr(13).replacen(" ",""))
	
	if command.substr(0,5) == "/help":
		return "Commands: \n/guns   lists all guns\n/give <gunname>  gives your player that gun\n/players   lists all players   click on a player in the leaderboard to copy their name\n/resetScores   resets everyone's scoreboard \n/reset   forces the game to reset immediately\n/maxHealth\n/setGunSpawnRate sets gun spawnrate per person\n/setStartGuns   sets the number of guns per person at the start of the match\n/kill <player>   kills the player. Doesn't work if they are invincible."
	
	
	
	return "not a command. /help for help"

func giveCommand(value):
	if gun_library.getAttributes(value) != null:
		Globals.player.pickUpGun(value)
		return "gave player a " + str(value)
	return str(value) + " is not valid"
	

func kickCommand(value):
	Globals.playersInServer = Globals.world.getPlayersInServer()
	
	if Globals.playersInServer.has(value):
		Globals.world.rpc_id(Globals.playersInServer[value],"leaveServer")
		return "kicked   " + str(value) + "   " + str(Globals.playersInServer[value])
	
	return "Could not find (and kick) player named " + value 


func maxGunSpawnRatesCommand(num):
	
	if !num.is_valid_float():
		return str(num) + "is not a number."
	
	var newRate = num.to_float()
	
	if newRate < 10000:
		var oldValue = Globals.gunSpawnRatePerPerson
		Globals.gunSpawnRatePerPerson = newRate
		return "Changed spawn rate per person from: " + str(oldValue)+" to: " +str(num)
	
	return "That would crash the game."
	

func gunSpawnsAtStartCommand(num):
	
	if !num.is_valid_int():
		return str(num) + "is not a number."
	
	var amount = num.to_int()
	
	if amount < 10000:
		var oldValue = Globals.gunSpawnsPerPersonAtStart
		Globals.gunSpawnsPerPersonAtStart = int(amount)
		return "Changed guns per person from: " + str(oldValue)+" to: " +str(num)
	
	return "That would crash the game."
	

func maxHealthCommand(num):
	
	if !num.is_valid_int():
		return str(num) + "is not a number."
	
	var newHealth = num.to_int()
	
	if newHealth > 10:
		Globals.world.setMaxHealth(newHealth)
		return "set max health"
	
	return "That health is too low."
	

func resetCommand():
	Globals.world.resetGame(-1)
	return "reseting"

func shutDownCommand(value):
	Globals.playersInServer = Globals.world.getPlayersInServer()
	
	if Globals.playersInServer.has(value):
		Globals.world.shutDown(Globals.playersInServer[value])
		return "shutdown   " + str(value) + "   " + str(Globals.playersInServer[value])
	
	return "Could not find player"

func killCommand(value):
	Globals.playersInServer = Globals.world.getPlayersInServer()
	
	if Globals.playersInServer.has(value):
		Globals.world.killPlayer(Globals.playersInServer[value])
		return "killed   " + str(value) + "   " + str(Globals.playersInServer[value])
	
	return "Could not find player"

func resetScoresCommand():
	Globals.world.resetScores()
	return "reset scores"

func listGuns():
	var temp = "Guns: " + "\n" 
	for gun in gun_library.getGunList():
		temp += gun.gunName + "\n" 
	
	
	return temp

func listPlayers():
	Globals.playersInServer = Globals.world.getPlayersInServer()
	
	var temp = "Players: " + "\n" 
	
	for player in Globals.playersInServer.keys():
		temp += "\"" + player + "\"    " + str(Globals.playersInServer[player])  + "\n" 
	
	return temp


#not command stuff
var killTween
func displayKill(playerName):
	
	var killIndicator = $allUi/"kill indicator"
	
	killIndicator.text = "Killed " + playerName
	
	if killTween:
		killTween.kill()
	
	killTween = create_tween()
	killTween.tween_property(killIndicator,"modulate", Color("ff1900"), 1).set_ease(Tween.EASE_OUT)
	killTween.tween_property(killIndicator,"modulate", Color(1,1,1,0), 2).set_ease(Tween.EASE_IN)
	
	

var scoreBoardTween
var winTween
func displayWin(playerName):
	
	var winIndicator = $allUi/winIndicator
	
	winIndicator.text = str(playerName) + " Won!"
	
	if winTween:
		winTween.kill()
	
	winTween = create_tween()
	winTween.tween_property(winIndicator,"modulate", Color("ffff00"), 0.5).set_ease(Tween.EASE_OUT)
	winTween.tween_property(winIndicator,"modulate", Color(1,1,1,0), 1).set_ease(Tween.EASE_IN)
	
	winTween.tween_property($allUi/ScoreBoard,"modulate", Color(1,1,1,1), 0.5).set_ease(Tween.EASE_OUT).set_delay(0.5)
	winTween.tween_property($allUi/ScoreBoard,"modulate", Color(1,1,1,0), 0.5).set_ease(Tween.EASE_IN).set_delay(5)
	
	
	
