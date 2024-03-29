extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func setType(type):
	
	params = (gun_library.getAttributes(type) as gun_attributes)
	
	$Sprite2D.texture = params.gunTexture
	$Sprite2D.offset = params.texOffset
	
	bulletsLeft = params.maxAmmo
	
	if Globals.avatar != null:
		Globals.avatar.setType(type)
	

var bulletsLeft #= Globals.gunParams.maxAmmo

var params : gun_attributes #= Globals.gunParams

var secondsUntilNextShot = 0
var bloom = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.avatar != null and params != null:
		Globals.avatar.setType(params.gunName)
	
	pass

func _physics_process(delta):
	
	if Globals.playerIsDead:
		queue_free()
	
	if !Globals.paused:
		rotation = (get_global_mouse_position() - global_position).angle() # + deg_to_rad(90)
	
	$Sprite2D.flip_v = false
	if (rotation > deg_to_rad(90) or rotation < deg_to_rad(-90)):
		$Sprite2D.flip_v = true
	
	
	if (secondsUntilNextShot > -1):
		secondsUntilNextShot -= delta 
	if !shootPressed() || Globals.paused:
		bloom = max(0,bloom - params.bloomDecay * delta)

	if shootPressed() && secondsUntilNextShot <= 0 && !isShootingIntoWall():
		
		secondsUntilNextShot = 1.0/params.fireRate
		if bulletsLeft <= 0:
			if !$emptyClick.playing:
				$emptyClick.play()
			else:
				secondsUntilNextShot = 0.05
		else:
			#do all bullet math
			var dir = (get_global_mouse_position() - global_position).normalized()
			var pos = global_position + (dir * params.length)
			var offset = params.bulletSpread + bloom
			offset *= randf() - 0.5
			dir = dir.rotated(deg_to_rad(offset))
			
			#create the bullet
			params.createBulletsLambda.call(pos,dir,true)
			
			#have the player recoil
			Globals.player.recoil(dir,params)
			Globals.avatar.setLastShotDir(dir)
			Globals.playerCamera.shake(0.2, params.recoil * 0.1)
			#get ready for next shot
			
			bloom = min(params.bloomMax,bloom + params.bloom)
			bulletsLeft -= 1
		
	elif Input.is_action_just_pressed("throw") and !Globals.paused:
		throw()
	
	
	Globals.ammo = bulletsLeft
	Globals.timeTillNextShot = secondsUntilNextShot
	Globals.maxTimeTillNextShot = 1.0/params.fireRate
	Globals.gunInaccuracyTotal = params.bulletSpread + bloom
	
	if Globals.avatar != null:
		Globals.avatar.setGunRotation(rotation,$Sprite2D.flip_v)
	

func shootPressed():
	if Globals.paused:
		return false
	return Input.is_action_pressed("shoot")

func isShootingIntoWall():
	if params.bullet.piercing:
		return false
	
	var dir = (get_global_mouse_position() - global_position).normalized()
	var pos = (dir * params.length)
	
	$wallCheck.global_rotation = 0
	$wallCheck.target_position = pos
	$wallCheck.force_raycast_update()
	
	return $wallCheck.is_colliding()
	



func throw():
	var dir = (get_global_mouse_position() - global_position ).normalized()
	Globals.avatar.setLastShotDir(dir)
	Globals.world.createThrownWeapon(global_position + (dir * 30),dir,params.gunName)
	Globals.player.holdingWeapon = false
	if Globals.avatar != null:
		Globals.avatar.setType("")
	queue_free()
	
	#prints("I just shot. I am: ",Globals.multiplayerId)
	

