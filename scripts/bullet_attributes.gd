extends Node2D

class_name bullet_attributes

#all measurements in pixels per second.

const bulletSpeedMultiplier = 1
const bulletBulletRangeMultiplier = 1
const bulletKnockbackMultiplier = 1

var bulletTexture : Texture2D
var firedNoise 
var texOffset : Vector2
var collisionShapeSize

var damage
var range
var speed
var knockback

var piercing

var onShootLambda : Callable = func(shooter,caller): #shooter is just an id 
	pass

var onHitLambda : Callable = func(shooter,target,caller): #shooter is just an id ; target is an object
	pass

# Constructor for bullet_attributes class
func _init(
	texture: Texture2D,
	firedNoise,
	offset: Vector2,
	collisionSize,
	bulletDamage,
	bulletRange,
	bulletSpeed,
	knockback,
	piercing,
	onShootFunc : Callable = onShootLambda,
	onHitFunc : Callable = onHitLambda
):
	bulletTexture = texture
	self.firedNoise = firedNoise
	texOffset = offset
	collisionShapeSize = collisionSize
	damage = bulletDamage
	range = bulletRange * bulletBulletRangeMultiplier
	speed = bulletSpeed * bulletSpeedMultiplier
	self.knockback = knockback * bulletKnockbackMultiplier
	self.piercing = piercing
	onShootLambda = onShootFunc
	onHitLambda = onHitFunc
