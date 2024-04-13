#extends Node2D
extends RigidBody2D
var args := {
	targetPlayer = null
}
var targetPlayer:Node2D

var coins := 2
@onready var enemy = $Enemy


@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var collision_shape_2d_2 = $CollisionShape2D2


var delta := 0.0

var points:Array[Vector2] = []

var max_speed = 180.0
var knockbackVel := Vector2.ZERO
var bellowKnockback := Vector2.ZERO
var frozen := false
var drainSpeed := 1.0

func _ready():
	if args.targetPlayer:
		targetPlayer = args.targetPlayer
	else:
		targetPlayer = Global.player
	
	enemy.spawn()

func _physics_process(delta):
	delta *= Global.timescale
	self.delta = delta

func _integrate_forces(state):
	knockbackVel = Utils.lexp(knockbackVel, Vector2.ZERO, 20.0 * delta)
	bellowKnockback = Utils.lexp(bellowKnockback, Vector2.ZERO, 2.8 * delta)
	if frozen:
		linear_velocity = knockbackVel + bellowKnockback
	else:
		var dir = targetPlayer.position - position
		var dist = dir.length()
		dir = dir.normalized()
		
		var speedScale = 1.0 - (1.0 / ((max(0.0, dist - 60.0) / 50.0) + 1.0))
		Global.debugVal.s = speedScale
		var speed = max(max_speed/3.33, speedScale * max_speed)
		
		var vel = dir * speed
		
		#position += vel * delta
		linear_velocity = vel + knockbackVel + bellowKnockback
	
	linear_velocity *= Global.timescale * drainSpeed
	angular_velocity *= Global.timescale

#func _draw():
	#draw_polyline(points, Color.YELLOW, 4.0, true)


func kill(soft := false):
	if not soft:
		Audio.play(preload("res://src/sounds/enemyDie.ogg"), 0.8, 1.2)
	#for i in 4:
		#Utils.spawn(preload("res://src/particle/enemy_pop/enemy_pop.tscn"), position, get_parent(), {color = line_2d.default_color})
	if Global.options.pEnemyPop:
		Utils.spawn(preload("res://src/particle/enemy_pop/enemy_pop2.tscn"), position, get_parent(), {color = Color(1, 0.792, 0.122)})
	
	Stats.stats.totalEnemiesKilled += 1
	Stats.metaStats.totalEnemiesKilled += 1
	
	queue_free()

func knockback(from:Vector2, power := 1.0, reset := false):
	var new = power*2000.0 * (position - from).normalized()
	knockbackVel = new if reset else knockbackVel + new
	enemy.flash()
