extends "res://src/player/player.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func _ready():
	for x in utils.customCharacters:
		if x.pos == Players.details[0].char:
			print(Players.details[0])
			behavior = Utils.spawn(load("res://mods-unpacked/"+Players.details[0].charMod+"/extensions/src/character/"+Players.details[0].charInt+"/"+Players.details[0].charInt+".scn"), Vector2.ZERO, self)
	super._ready()
