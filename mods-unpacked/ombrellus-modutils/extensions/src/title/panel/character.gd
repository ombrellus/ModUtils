extends "res://src/title/panel/character.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

var charName:String
var charVisualName:String
var mod:String = "booby sex"
var moddedReady:bool = false
var topTex
var botTex

func _ready():
	super._ready()
	var List = Players.unlockedCharList
	
	if OS.has_feature("editor"):
		List = Players.charList
	
	char = List[Global.title._charId-1]
	if char >= 7:
		for x in utils.customCharacters:
			if x.pos == char:
				charName = x.name
				mod = x.mod
				charVisualName = x.gameName
				topTex = x.icon
				botTex = x.icon_bg
				overwrite = x.overwrite
		moddedReady = true
		updateChar()
	size = Vector2i(50,50)

func updateChar():
	super.updateChar()
	if moddedReady:
		char_icon.texture = topTex
		char_icon_bg.texture = botTex
		if overwrite:
			if colorState == 0:
				char_icon.modulate = color
				char_icon_bg.modulate = color
		button.title = charVisualName
		button.update()

func startGame():
	print("run modUtils")
	super.startGame()
	Players.details = [{
		char = char,
		charInt = charName,
		color = color,
		bgColor = Color.TRANSPARENT,
		colorState = colorState,
		skin = skin,
		charMod = mod
	}]
	print("before save data")
	print(Players.details[0].charMod)
	Players.saveData(true)
	print("after save data")
	print(Players.details[0].charMod)
	
