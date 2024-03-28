extends "res://src/title/panel/character.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

var charName:String
var charVisualName:String
var mod:String
var ext:String = ".svg"
var moddedReady:bool = false

func _ready():
	super._ready()
	if Global.title._charId>= 7:
		print(Players.unlockedCharList)
		for x in utils.customCharacters:
			if x.pos == Global.title._charId:
				charName = x.name
				mod = x.mod
				charVisualName = x.gameName
				ext = x.img
		moddedReady = true
		updateChar()

func updateChar():
	super.updateChar()
	if moddedReady:
		char_icon.texture = load("res://mods-unpacked/"+mod+"/extensions/src/character/"+charName+"/top"+ext)
		char_icon_bg.texture = load("res://mods-unpacked/"+mod+"/extensions/src/character/"+charName+"/back"+ext)
		button.title = charVisualName
		button.update()

func startGame():
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
	Players.saveData(true)
	
