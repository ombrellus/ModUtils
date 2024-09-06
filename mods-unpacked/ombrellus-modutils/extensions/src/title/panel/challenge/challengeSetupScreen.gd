extends "res://src/title/panel/challenge/challengeSetupScreen.gd"

@onready var OMutils = get_node("/root/ModLoader/ombrellus-modutils")

func _ready():
	for c in OMutils.customCharacters:
		charList.append(c.pos)
	for i in OMutils.customUpgrades:
		var pipi:Dictionary = OMutils.customUpgrades[i]
		if pipi.has("challenge"):
			if pipi.challenge: 
				itemData[i] = {
					icon = pipi.challengeIcon,
					cost = pipi.challengeCost
				}
	super._ready()

func startGame():
	super.startGame()
	if loadout.char >= 8:
		var _name
		var _mod
		for x in OMutils.customCharacters:
			if x.pos == loadout.char:
				_name = x.name
				_mod = x.mod
		Players.details = [{
			char = loadout.char,
			charInt = _name,
			charMod = _mod,
			color = loadout.color,
			bgColor = Color.TRANSPARENT,
			colorState = loadout.colorState,
			skin = ""
	}]
