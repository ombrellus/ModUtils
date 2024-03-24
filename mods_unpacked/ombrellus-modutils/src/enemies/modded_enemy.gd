extends Node
@onready var parent:Node2D = get_parent()
@export var health := 1.0
var buff := 0.0
@onready var area_2d = $"../Area2D"
@export var grow := true
var hitboxRadius := 20.0
var playerDelta := 0.0
var flashTimer := 0.0
var flashColor := Color.WHITE
var inDrain := false
var drainSpeed := 1.0
var drainTimer := 0.2
var freezeTimer := 0.0
var lastDamagePoint := Vector2.ZERO
var killed := false
var invincible := false
var inBullet:Node2D
var inBulletTimer := 0.0
var ignore := []
func _init():
	buff = floor(Global.difficultyScale)
	buff += pow(randf(), 6.0) * max(0.0, Global.gameTime - 60*5)/60.0
func _ready():
	area_2d.body_entered.connect(hit)
	area_2d.body_exited.connect(hitExit)
	area_2d.area_entered.connect(hit)
	area_2d.area_exited.connect(hitExit)
	parent.add_to_group("enemy")
	Game.bellow.connect(onBellow)
	Events.pUpdate.connect(func():
		if parent.is_in_group("boss"):
			parent.visible = Global.options.pBoss
		else:
			parent.visible = Global.options.pEnemy
	)
	Events.lastStandUpdated.connect(func():
		if "targetPlayer" in parent:
			if parent.targetPlayer.dead:
				parent.targetPlayer = Game.randomPlayer()
	)
	var shape = area_2d.get_child(0)
	if shape and "radius" in shape.shape:
		hitboxRadius = shape.shape.radius
	(func():
		if shape and "radius" in shape.shape:
			hitboxRadius = shape.shape.radius
	).call_deferred()
func spawn():
	if grow:
		parent.scale = Vector2.ZERO
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(parent, "scale", Vector2(1.0, 1.0), 0.2)
func _process(delta):
	playerDelta = delta * Global.playerTimescale
	delta *= Global.timescale
	flashTimer = max(0.0, flashTimer - 10.0 * playerDelta)
	var flashValue = 1.0 + 200.0 * flashTimer
	if flashColor == Color.WHITE:
		parent.modulate = Color(flashValue, flashValue, flashValue, 1.0)
	else:
		parent.modulate = Color(flashValue, 1.0 - pow(flashTimer, 4.0),  1.0 - pow(flashTimer, 4.0), 1.0)
	if inDrain:
		if Global.drain >= 2:
			drainSpeed = 0.2
		drainTimer -= 1.0 * delta
		if drainTimer <= 0.0:
			drainTimer = 1.0 - 0.85 * Global.drainTickRate
			drainTick()
	else:
		drainSpeed = 1.0
	if "drainSpeed" in parent:
		parent.drainSpeed = drainSpeed
	freezeTimer -= 1.0 * delta
	if freezeTimer > 0.0:
		parent.frozen = true
	else:
		parent.frozen = false
	if inBullet:
		inBulletTimer -= 1.0 * delta
		if inBulletTimer <= 0.0:
			inBulletTimer = 0.1
			hit(inBullet)
func _physics_process(delta):
	pass
func flash(red := false):
	flashColor = Color(1.0, 0.0, 0.0, 1.0) if red else Color.WHITE
	flashTimer = 2.0 if red else 1.0
func checkOverlaps():
	for a in area_2d.get_overlapping_areas():
		hit(a)
	for a in area_2d.get_overlapping_bodies():
		hit(a)
func hit(body):
	if invincible:
		return
	if not body or not is_instance_valid(body):
		return
	var bodyParent = body.get_parent()
	lastDamagePoint = body.global_position - parent.global_position
	var knockbackPower := 1.5 if Global.torrentActive and Global.torrent >= 2 else 1.0
	if body.is_in_group("finger"):
		if Global.freezing > 0:
			freeze()
		damage(body.damage)
	elif body.is_in_group("bullet"):
		bodyParent.hitEnemy(parent)
		if "hitBullet" in parent:
			parent.hitBullet(bodyParent)
		if Global.freezing > 0:
			freeze()
		damage(bodyParent.damage)
		if body.is_in_group("charge_bullet"):
			inBullet = body
	elif body.is_in_group("laser"):
		lastDamagePoint = Vector2.ZERO
		if "knockback" in parent:
			if body.has_meta("source_node"):
				parent.knockback(body.get_meta("source_node").global_position, 0.4 * knockbackPower, true)
			else:
				parent.knockback(body.get_parent().global_position, 0.4 * knockbackPower, true)
		if "hitBullet" in parent:
			parent.hitBullet(bodyParent)
		if Global.freezing > 0:
			freeze()
		if Global.splashDamage > 0 and Global.options.pSplash and Game.checkBulletSplash():
			Utils.spawn(preload("res://src/element/bullet_splash/bullet_splash.tscn"), parent.position, parent.get_parent(), {target = parent})
		damage(bodyParent.damage)
		inBullet = body
	elif body.is_in_group("slash"):
		if ignore.has(body):
			return
		ignore.push_back(body)
		if "knockback" in parent:
			if parent.is_in_group("slime_segment"):
				knockbackPower *= 0.5
			if body.has_meta("source_node"):
				parent.knockback(body.get_meta("source_node").global_position, 0.4 * knockbackPower, true)
			else:
				parent.knockback(body.get_parent().global_position, 0.4 * knockbackPower, true)
		if "hitBullet" in parent:
			parent.hitBullet(bodyParent)
		if Global.freezing > 0:
			freeze()
		var damage = body.get_meta("damage", 0)
		if damage == 0:
			damage = bodyParent.damage
		if Global.splashDamage > 0 and Global.options.pSplash and Game.checkBulletSplash():
			Utils.spawn(preload("res://src/element/bullet_splash/bullet_splash.tscn"), parent.position, parent.get_parent(), {target = parent})
		damage(damage)
	elif body.is_in_group("bullet_splash"):
		if not parent == bodyParent.target:
			bodyParent.hitEnemy(parent)
			damage(bodyParent.damage)
	elif body.is_in_group("player"):
		body.hitEnemy(parent)
func hitExit(body):
	if inBullet and is_instance_valid(body) and inBullet == body:
		inBullet = null
func damage(amount:float, bypass := false, pos := Vector2.INF):
	if parent.has_meta("damageCheck"):
		if parent.get_meta("damageCheck") == true:
			amount = parent.damageCheck(amount)
	if invincible and not bypass:
		return
	if not pos == Vector2.INF:
		lastDamagePoint = pos
	Audio.play(preload("res://src/sounds/hit3.ogg"), 0.8, 1.2)
	flash()
	health -= amount
	if "hitCallback" in parent:
		parent.hitCallback(amount, lastDamagePoint)
	updateHealth()
func drainTick():
	if invincible:
		return
	Audio.play(preload("res://src/sounds/hit3.ogg"), 0.8, 1.2)
	flash(true)
	health -= 1.0
	updateHealth()
func updateHealth():
	if health <= 0.0 - buff:
		if not killed:
			killed = true
			var count = 0
			if "coins" in parent:
				count = parent.coins
			if count > 0:
				Game.spawnCoins(count, parent.global_position)
			var count2 = 0
			if "extraCoins" in parent:
				count2 = parent.extraCoins
			if count2 > 0:
				Game.spawnCoins(count2, parent.global_position, true, 0)
			parent.kill()
			if not Global.attemptStarted:
				Global.attemptStarted = true
				Global.attemptCounter = 1
func freeze(dur := 0.0):
	if dur > 0:
		freezeTimer = max(freezeTimer, dur)
	else:
		freezeTimer = max(freezeTimer, 0.1 + 0.2 * Global.freezing)
func onBellow(player:Node2D):
	if Global.bellow >= 2:
		if "bellowKnockback" in parent:
			var radius = 700.0 + 60.0 * (Global.bellow-1)
			var vel = 2300.0 + 200.0 * (Global.bellow-1)
			var diff = parent.position - player.position
			var dist = diff.length()
			var dir = diff.normalized()
			var amount = max(0.0, 1.0 - (1.0 / (1.5/radius * max(0.0, radius-dist) + 1.0)))
			Utils.processLater(self, (dist / 100.0) * 100.0, func():
				parent.bellowKnockback = vel * dir * amount
				if Global.bellow >= 3:
					damage(amount * 20.0 * pow(Global.bellow-2, 1.5))
			)
		if "bellowKnockbackTimer" in parent:
			parent.bellowKnockbackTimer = 1.0
