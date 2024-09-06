extends "res://src/ui/multiplayer/player_slot/player_slot.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

var charName:String
var charVisualName:String
var mod:String
var moddedReady:bool = false
var topTex
var botTex

func updateChar(setState:bool =false):
	super.updateChar(setState)
	if Players.details[index].char >= 8:
		for x in utils.customCharacters:
			if x.pos == Players.details[index].char:
				charName = x.name
				mod = x.mod
				charVisualName = x.gameName
				topTex = x.icon
				botTex = x.icon_bg
				Players.details[index].charMod = x.mod
				Players.details[index].charInt = x.name
		char_icon.texture = topTex
		char_icon_bg.texture = botTex
		char_name.text = charVisualName
	else:
		Players.details[index].charMod = null
		Players.details[index].charInt = null
	print(Players.details[index])
	print(Players.details)
	

func _ready():
	super._ready()
	var List = Players.unlockedCharList
	
	if OS.has_feature("editor"):
		List = Players.charList
	
	if List[charIndex] >= 7:
		for x in utils.customCharacters:
			if x.pos == List[charIndex]:
				charName = x.name
				mod = x.mod
				charVisualName = x.gameName
				topTex = x.icon
				botTex = x.icon_bg
		updateChar()
