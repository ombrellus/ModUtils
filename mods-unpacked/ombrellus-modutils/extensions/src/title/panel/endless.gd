extends "res://src/title/panel/endless.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func _ready():
	var curMode
	if has_meta("custGame"):
		curMode = utils.customGamemodes[utils.selectingGamemode]
		print(curMode)
		utils.selectingGamemode+=1
		button.text = curMode.name
		bg.texture = curMode.icon
		bg.modulate = curMode.color
		button.update()
	else:
		utils.selectingGamemode = 0
		curMode = {mod="node",name="none",call=func():pass,enemy=true,boss=true,timer=0}
	button.click.connect(func():
		if has_meta("custGame"):
			utils.selectedGamemode= curMode.name
			utils.gamemodeMod= curMode.mod
			utils.gaymodeCall = curMode.call
			utils.customGamemodeArgs = {timer=curMode.timer,enemy=curMode.enemy,boss=curMode.boss}
		else:
			utils.selectedGamemode= "none"
			utils.gamemodeMod= "none"
			utils.gaymodeCall = func():pass
			utils.customGamemodeArgs = {timer=0,enemy=true,boss=true}
	)
	super._ready()
	button.click.connect(func():
		if curMode.timer != 0.0:
			Players.timedMode = true
			Global.timedModeLimit = 60.0 * curMode.timer
		else:
			Players.timedMode = false
			Global.timedModeLimit = 60.0 * 20.0
		)
	
