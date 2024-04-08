extends "res://src/autoload/players.gd"

@onready var utils:Node = get_node("/root/ModLoader/ombrellus-modutils")

func updateUnlocks():
	super.updateUnlocks()
	if utils != null:
		for i in utils.customCharacters:
			unlockedCharList.push_back(i.pos)
