extends "res://src/enemy/enemy.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func hit(body):
	super.hit(body)
	if body.is_in_group("bullet") or body.is_in_group("finger") or body.is_in_group("laser") or body.is_in_group("bullet_splash") or body.is_in_group("slash"):
		utils.enemyHit.emit(parent, body)
		
