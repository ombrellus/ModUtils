extends Node

var nemici:bool = true
var boss:bool = true

var maxAmbush:float = 30.0
var ambush:float = 30.0

var counters:Array[HBoxContainer]

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func _ready():
	ambush = maxAmbush
	var cont:HBoxContainer
	if not utils.customCurrencies.is_empty():
		cont = HBoxContainer.new()
		cont.size = Vector2(138,44)
		cont.position = Vector2(6,41)
		cont.add_theme_constant_override("separation",6)
		Global.ui.get_node("Container").add_child(cont)
		
	for c in utils.customCurrencies:
		var entry = utils.customCurrencies[c]
		if entry.shop:
			utils.shops.append(c)
		if entry.show == true:
			var counter:HBoxContainer = preload("res://src/ui/coin_count/coinCount.tscn").instantiate()
			counter.type = c
			counter.update
			cont.add_child(counter)
			counters.append(counter)


func _process(delta):
	if not counters.is_empty():
		for c in counters:
			c.text = str(utils.customCurrencies[c.type].check.call())
	if Global.paused: return
	if Global.curAbility >= 8:
		if not Global.escaped and Global.abilityCooldown > 0.0:
			Players.charData[Global.curAbility].abilityCooldown.call(delta)
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
