extends "res://src/title/panel/newRun.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func _ready():
	super._ready()
	var games:Array[PackedScene]
	for i in utils.customGamemodes:
		games.append(load("res://mods-unpacked/ombrellus-modutils/extensions/src/title/panel/custGame.tscn"))
	button.click.connect(func():
		Global.title.switch(self)
		var win = Utils.find(Global.title.windows.values(), func(v):
			return v.window == self)
		var oldChild = win.childrenIds
		print(oldChild)
		Global.title.split(self, games)
		print(win.childrenIds)
		win.childrenIds += oldChild
		print(win.childrenIds)
	)
	
