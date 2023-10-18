extends Node2D


var deadZone = 10

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	
	$address.text = Globals.internalAddress if  Globals.internalAddress != null else ""
	$CheckBox.visible = Globals.is_server
	pass


func _process(delta):
	
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Globals.paused = true
	
	if Input.is_action_just_pressed("shoot"):
		#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		Globals.paused = false
		pass
	
	if Globals.player == null:
		return
	
	$Health.value = Globals.playerHealth
	$Health.max_value = Globals.maxPlayerHealth
	
	$dashCount.value = Globals.dashRechargePercet
	$dashCount.max_value = 1
	
	$dashCool.value = 1-Globals.dashCool
	$dashCool.max_value = 1
	
	$bulletIndicator.text = "Bullets left: " + str(Globals.ammo)
	$bulletIndicator.visible = Globals.player.holdingWeapon
	
	$reload.value = Globals.maxTimeTillNextShot-Globals.timeTillNextShot
	$reload.max_value = Globals.maxTimeTillNextShot
	$reload.visible = Globals.player.holdingWeapon
	
	
	
	if Globals.playerIsDead:
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
		position = Vector2.ZERO
	
	if Time.get_ticks_msec() > timeToCloseCommandLine and !Globals.commandLineOpen:
		$commandLineLabel.visible = false
	

var timeToCloseCommandLine = 0

func _input(event : InputEvent) -> void:
	
	if Globals.playerIsDead:
		return
	
	if event is InputEventMouseMotion:
		var _target = event.position - get_viewport().size * 0.5
		
		_target = get_global_mouse_position() - global_position
		
		
		
		if _target.length() < deadZone:
			position = Vector2(0,0)
		else:
			position = _target.normalized() * (min(600,_target.length()) - deadZone) * 0.5
	
	if event.is_action_pressed("commandLine") and Globals.is_server:
		$commandLine.visible = true
		$commandLineLabel.visible = true
		Globals.commandLineOpen = true
		$commandLine.grab_focus()
	if event.is_action_pressed("enter"):
		if Globals.commandLineOpen:
			Globals.commandLineOpen = false
			$commandLine.visible = false
			$commandLine.release_focus()
			$commandLineLabel.text += takeCommand($commandLine.text) + "\n"
			$commandLineLabel.text = trimCommandLineLabel($commandLineLabel.text,30)
			$commandLine.text = ""
			
			timeToCloseCommandLine = Time.get_ticks_msec() + 3000
			
	
	


func _on_check_box_toggled(button_pressed):
	$address.visible = button_pressed
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
	
	
	if command.substr(0,5) == "/help":
		return "Commands: \n/guns   lists all guns\n/give <gunname>  gives your player that gun"
	
	
	return "not a command"

func giveCommand(value):
	if gun_library.getAttributes(value) != null:
		Globals.player.pickUpGun(value)
		return "gave player a " + str(value)
	return str(value) + " is not valid"
	

func listGuns():
	var temp = "Guns: " + "\n" 
	for gun in gun_library.getGunList():
		temp += gun.gunName + "\n" 
	
	
	return temp

