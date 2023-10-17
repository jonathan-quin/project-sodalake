extends CharacterBody2D

const SPEED = 300
const ACCELERATION = 10
const DECCELERATION = 20

var dashDistance = 150
var dashSpeed = 1800
var dashStart = Vector2.ZERO
var isDashing = false
var dashDirection = Vector2.ZERO

var DASHCOOLDOWN = 0.2 #seconds
var dashWait = 0.2
var MAXDASHES = 3
var dashes = 3
var DASHRECHARGE = 2 #seconds
var dashRechargeProgress = 2 #seconds

var avatar

var holdingWeapon = true
var nonsense = false
var health = 100

var dead = true

func _ready():
	
	$debug.text = str(Globals.multiplayerId)
	
	
	
	Globals.player = self
	

func _physics_process(delta):
	
	if dashes < MAXDASHES:
		dashRechargeProgress += delta
		if dashRechargeProgress >= DASHRECHARGE:
			dashes += 1
			dashRechargeProgress = 0
	
	if Globals.resetting:
		updateAvatar()
		return
	
	if dead:
		Globals.playerIsDead = true
		$Icon.rotation = deg_to_rad(90)
		if (avatar != null):
			avatar.rotation = deg_to_rad(90)
		holdingWeapon = false
		return
	
	if Globals.commandLineOpen:
		updateAvatar()
		return
	
	dashWait = max(dashWait-delta,-1)
	
	var targetVelocity = Vector2()
	if Input.is_action_pressed("right"):
		targetVelocity.x += 1
	if Input.is_action_pressed("left"):
		targetVelocity.x -= 1
	if Input.is_action_pressed("down"):
		targetVelocity.y += 1
	if Input.is_action_pressed("up"):
		targetVelocity.y -= 1
	
	if Input.is_action_just_pressed("dash") and dashWait <= 0 and dashes > 0:
		dashes -= 1
		dashDirection = targetVelocity # get_global_mouse_position()-global_position
		if dashDirection != Vector2.ZERO:
			dashStart = global_position
			isDashing = true
			
	
	# Input handling
	if !isDashing:
		#targetVelocity = targetVelocity.rotated((global_position-get_global_mouse_position()).angle() - deg_to_rad(90))
		
		targetVelocity *= SPEED
		
		if (targetVelocity != Vector2.ZERO):
			velocity = lerp(velocity,targetVelocity,delta * ACCELERATION)
		else:
			velocity = lerp(velocity,targetVelocity,delta * DECCELERATION)
		
		move_and_slide()
	else:
		velocity = dashDirection.normalized() * dashSpeed
		
		if move_and_slide() || (dashStart-global_position).length() > dashDistance:
			isDashing = false
			dashWait = DASHCOOLDOWN
		
	
	updateAvatar()
	
	Globals.playerHealth = health
	Globals.playerDashes = dashes
	




func updateAvatar():
	if avatar != null:
		avatar.position = position
		

var gunPath = preload("res://scenes/gun.tscn")
func pickUpGun(type):
	if holdingWeapon:
		return
	
	var newGun = gunPath.instantiate()
	newGun.setType(type)
	
	add_child(newGun)
	
	holdingWeapon = true
	

func takeParamDamage(dir,projectile):
	
	if projectile is bullet_attributes:
		health -= projectile.damage
		velocity += dir.normalized() * projectile.knockback
	elif projectile is gun_attributes:
		health -= projectile.throwDamage
	else:
		return
	
	Globals.playerHealth = health
	
	if health <= 0:
		if !dead:
			Globals.world.died()
		dead = true
	
	#print(health)
	

func takeDamage(dir,knockback,damage):
	
	health -=damage
	velocity += dir.normalized() * knockback
	
	Globals.playerHealth = health
	
	if health <= 0:
		if !dead:
			Globals.world.died()
		dead = true
	
	#print(health)
	

func reset():
	var gun = get_node_or_null("gun")
	if gun != null:
		gun.queue_free()
	
	avatar.rotation = 0
	$Icon.rotation = 0
	
	health = Globals.maxPlayerHealth
	
	Globals.resetting = false
	holdingWeapon = false
	dead = false
	

func goToPosition(pos):
	
	Globals.resetting = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position", pos, 0.5)
	tween.tween_callback(self.reset)
	

func recoil(dir,gun : gun_attributes):
	velocity -= dir.normalized() * gun.recoil


