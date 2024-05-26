extends Node

var nemici:bool = true
var boss:bool = true

var maxAmbush:float = 30.0
var ambush:float = 30.0

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func _ready():
	ambush = maxAmbush

func _process(delta):
	if Global.paused: return
	if not nemici:
		Global.main.spawnTimer = 46
	if not boss:
		Global.main.bossTimer = 46
	if Global.gameTime> 5*60 and not utils.ambushes.is_empty():
		if ambush>0:
			ambush -= delta
		else:
			spawnAmbush()

func spawnAmbush():
	ambush = maxAmbush
	var choices:Array[Dictionary] = utils.ambushes.duplicate(true)
	for i in choices:
		if  (Global.gameTime - 5*60) < i.delay*60 and i.delay != 0.0:
			choices.remove_at(choices.find(i))
	if choices.is_empty():
		#print("no shit")
		return
	var chosen = Utils.weightedRandom(choices)
	print(Utils.spawn(chosen.type,Global.main.getOutsidePosition(),Global.gameArea))
