extends "res://src/player/player.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

var doneSetUp:bool = false

# im going insane
func updateChar(foward:=true):
	super.updateChar(foward)
	if not doneSetUp:
		for x in utils.customCharacters:
			print(x.pos)
			print(Players.details[playerCharIndex].char)
			if x.pos == Players.details[playerCharIndex].char:
				behavior = Utils.spawn(utils._checkForScene("res://mods-unpacked/"+Players.details[playerCharIndex].charMod+"/extensions/src/character/"+Players.details[playerCharIndex].charInt+"/"+Players.details[playerCharIndex].charInt), Vector2.ZERO, self)
		doneSetUp = true

func useAbility(delta):
	super.useAbility(delta)
	var _ability = ability
	if Global.overwriteAbilityChar >= 0:
		_ability = Players.charData[Global.overwriteAbilityChar].ability
	print(_ability)
	if _ability >= 8:
		print("hello")
		Players.charData[_ability].useAbility.call(_ability,self)
