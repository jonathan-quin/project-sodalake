extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var timeUntilNextSpawn = 1
var spawnrate = 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	
	if !Globals.is_server:
		return
	
	var noSpawnTime = 2000
	var playersInServer = Globals.playersInServer.keys().size()
	
	var timeSinceRoundStart = Time.get_ticks_msec() - Globals.lastRoundStart - noSpawnTime
	if timeSinceRoundStart < 0:
		spawnrate = 1
		return
	spawnrate = playersInServer * 2 * (pow(1.002,-0.15*timeSinceRoundStart)) + 0.1 * playersInServer
	
	timeUntilNextSpawn -= delta
	
	#print(spawnrate)
	
	if timeUntilNextSpawn < 0:
		
		spawnGun()
		timeUntilNextSpawn = 1.0/spawnrate
		
		#spawnrate = randf_range(1.0/2,1.0/5)
		
	
	pass

func spawnGun():
	
	#-950 -450 to 1600 1050
	
	while true:
		
		$wallDetect.position.x = randf_range(-950,1600)
		$wallDetect.position.y = randf_range(-450,1050)
		
		$wallDetect/RayCast2D.force_raycast_update()
		$wallDetect/RayCast2D2.force_raycast_update()
		
		if !$wallDetect/RayCast2D.is_colliding() && !$wallDetect/RayCast2D2.is_colliding():
			break
		
	Globals.world.createGunPickup($wallDetect.position,gun_library.getRandomGunName())
	
	

