extends Node2D

var root:Node2D
@onready var canvas = $canvas
@onready var flash_canvas = $flashCanvas
@onready var char_bg = $canvas/charBG
@onready var char_fg = $canvas/charFG
@onready var char_flash_bg = $flashCanvas/charFlashBG
@onready var char_flash_fg = $flashCanvas/charFlashFG

@onready var Bullet = preload("res://src/element/bullet/bullet.tscn")

@onready var mod = get_node("/root/ModLoader/yourname-modname")

var shootTimer = 0.0

func init():
	pass

func _ready():
	#canvas.draw.connect(draw)
	#flash_canvas.draw.connect(draw)
	updateChar()

func updateChar():
	#sprite.modulate = root.color
	#char_bg.modulate = root.bgColor
	#canvas.queue_redraw()
	#flash_canvas.queue_redraw()
	pass

func _process(delta):
	#Abilty cooldown needs to me manually changed if you have a modded usable ability
	if not Global.escaped:
		if Global.abilityCooldown > 0.0:
			var speed = 1.0/(25.0 - TorCurve.smoothCorner(max(1, mod.coolAbility), 19.0, 1.8, 2.8)) * delta
			Global.abilityCooldown -= speed

func updateAttack(delta):
	shootTimer -= 1.0 * delta
	if shootTimer <= 0.0 and root.shooting > 0.0:
		#shootTimer = 1.0 / (0.36 * (Global.fireRate - 1.0 * Global.multiShot) + (1.0 / 0.4))
		#shootTimer = 1.0 / (0.36 * (Global.fireRate) + (1.0 / 0.4))
		if Global.torrentActive:
			shootTimer = 0.2 - 0.1 * TorCurve.smoothCorner(Global.fireRate/15.0, 1.0, 1.0, 4.0)
		else:
			shootTimer = 0.95 / (0.3 * pow(Global.fireRate, 1.15) + (1.0 / 0.4))
			shootTimer *= 1.0 + (0.33 * pow(Global.multiShot + Global.multiShotExtra, 0.75))
		
		var count := float(Global.multiShot + Global.multiShotExtra) + 1.0
		var spread = min(TAU, (0.8*(count-0.66)) * TAU / 32.0)
		
		Audio.play(preload("res://src/sounds/shoot2.ogg"), 0.8, 1.2)
		for i in count:
			var a = 0.0
			if count > 1:
				a = ((i) / (count - 1.0)) - 0.5
			var angle2 = root.aimAngle.rotated(a * spread)
			Utils.spawn(Bullet, root.position, root.get_parent(), {angle = angle2})
			Stats.stats.totalBulletsFired += 1
			Stats.metaStats.totalBulletsFired += 1
		

func updateMove(delta):
	root.velocity = Utils.lexp(root.velocity, root.moveDir * root.max_speed, 20.0 * delta)

#func draw():
	#if not (Global.save.specialFace and Global.options.showFace):
		#canvas.draw_circle(Vector2.ZERO, 16.0, root.bgColor)
		#canvas.draw_arc(Vector2.ZERO, 16.0, 0.0, TAU, 30, Color.BLACK, 10.0, true)
		#canvas.draw_arc(Vector2.ZERO, 16.0, 0.0, TAU, 30, root.color, 3.3, true)
