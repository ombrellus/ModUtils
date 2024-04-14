extends Node

var nemici:bool = true
var boss:bool = true

func _process(delta):
	if not nemici:
		Global.main.spawnTimer = 46
	if not boss:
		Global.main.bossTimer = 46
