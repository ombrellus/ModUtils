# Our base script is the original game script.
extends "res://src/player/player.gd"

# This overrides the method with the same name, changing the value of its argument:
func _ready():
	super._ready()
	
	print_debug("i'm the player!")
	Utils.place(preload("res://mods-unpacked/torcado-nametag/extensions/src/player/nametag.tscn"), self)
