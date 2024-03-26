extends "res://src/main/main.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func _init():
	Utils.runLater(500,func():super._init())
	

func _ready():
	super._ready()
	print("did")
	enemySelection.append_array(utils.customEnemies)
	print(enemySelection)
	print("done")
