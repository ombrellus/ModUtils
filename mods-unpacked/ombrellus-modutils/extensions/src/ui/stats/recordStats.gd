extends "res://src/ui/stats/recordStats.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func updateChoices():
	super.updateChoices()
	for x in utils.customCharacters:
		charChoices[x.pos] = load("res://mods-unpacked/"+x.mod+"/extensions/src/character/"+x.name+"/top"+x.img)
	character_cycle.choices = charChoices.values()
