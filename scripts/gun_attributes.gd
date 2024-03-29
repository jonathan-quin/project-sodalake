extends Node

class_name gun_attributes

var TEXOFFSETSCALE = 1.2

var gunName 

var commoness = 100

var gunTexture : Texture2D
var length
var texOffset


var maxAmmo = 0
var fireRate = 0
var recoil = 0
var bulletSpread = 0

var bloom = 0
var bloomMax = 0
var bloomDecay = 0

var throwSpeed = 0
var throwDamage = 0



var bullet : bullet_attributes


var canRatHave = true
func setCanRatHave(canRatHave):
	self.canRatHave = canRatHave
	return self



var createBulletsLambda : Callable = func(pos, dir, shotByPlayer = false):
	Globals.world.createBullet(pos,dir,gunName,shotByPlayer)


func _init(
	gunName,
	commoness,
	texture: Texture2D,
	gunLength,
	offset,
	ammoCount,
	rate,
	recoil,
	spread,
	bloom,
	bloomMax,
	bloomDecay,
	speed,
	damage,
	
	bulletType,
	_createBulletsLambda = createBulletsLambda
):
	self.gunName = gunName
	self.commoness = commoness
	gunTexture = texture
	texOffset = offset * TEXOFFSETSCALE
	maxAmmo = ammoCount
	fireRate = rate
	self.recoil = recoil
	bulletSpread = spread
	self.bloom = bloom
	self.bloomMax = bloomMax
	self.bloomDecay = bloomDecay
	throwSpeed = speed
	throwDamage = damage
	length = gunLength
	bullet = bulletType
	self.createBulletsLambda = _createBulletsLambda


