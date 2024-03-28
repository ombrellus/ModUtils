extends Node

const AUTHORNAME_MODNAME_DIR := "ombrellus-modutils"
const AUTHORNAME_MODNAME_LOG_NAME := "ombrellus-modutils:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

signal enemyHit
signal onMain
signal bossSpawned
signal enemySpawned
signal bossDied
signal enemyDied
signal itemBought
signal upgradeBought
signal bossQueueUpdated

var customUpgrades:Dictionary = {}
var customCharAbility:Dictionary = {}

var customEnemies:Array[Dictionary] = []
var customBosses:Array[Dictionary] = []
var customBossQueue:Array[Dictionary] = []
var customCharacters:Array[Dictionary] =[]

var characterNum:int
var allCharacterNum:int
var coolAbility:int = 0
var oldBossesKilled:int = 0
var oldEnemiesKilled:int = 0


var myCharacter:Dictionary ={
		internalName = "archer",
		displayName = "belloCacco",
		ability = 2,
		wallShrinkSpeed = 1.0,
		wallResistance = 1.0,
		priceScale = 1.0,
		skins = [""],
		spritesExtension = ".png",
		unlocked = true,
	}
var charAbility:Dictionary={
		internalName = "cool",
		name = (func()->Array:
			return ["cool"]
			),
		icon = (func()->Array:
			return [preload("res://src/ui/upgrade_shop/halt.svg")]
			),
		priceType = 1,
		value = (func():
			return coolAbility
			),
		price = (func(): 
			return (coolAbility+1)
			),
		buy = (func():
			coolAbility += 1
			Global.abilityCount += 1
			Global.usableAbilityCount += 1
			print("too lazy to remove those")
			print(coolAbility)
			),
		description = (func():
			var list = [
				"piss",
				"idk",
				"you tell me"
			]
			if coolAbility < list.size():
				return list[coolAbility]
			return ""
			),
		weight = 1.0
	}
var testItem:Dictionary = {piss = {
		internalName = "piss",
		name = (func()->Array: return ["piss"]
			),
		icon = (func()->Array: return [preload("res://src/ui/shop/speed.svg")]
			),
		priceType = 0,
		value = (func(): 
			return Global.multiShot
			),
		price = (func(): 
			var total := 0
			for d in Players.details:
					total += round((20 + pow(2, 3.5*pow(Global.multiShot, 0.5) + 4.0)) * Players.charData[d.char].priceScale)
			return total
			),
		buy = (func():
			Global.multiShot += 3
			),
		weight = 1,
		baseWeight = 0.2,
	}}

#region LOADING SHIT

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(AUTHORNAME_MODNAME_DIR)
	# Add extensions
	extensions_dir_path = mod_dir_path.path_join("extensions")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/title/panel/character.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/ui/stats/recordStats.gd")

func install_script_extensions() -> void:
	
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/enemy/enemy.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/ui/shop/shop.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/ui/shop/shopItem.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/ui/upgrade_shop/upgradeShopItem.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/player/player.gd")

func _on_current_config_changed(config: ModConfig) -> void:
	# Check if the config of your mod has changed!
	if config.mod_id == AUTHORNAME_MODNAME_DIR:
		if Global.main != null and config.data.debug:
			_debugWindow()

func _ready() -> void:
	install_script_extensions()
	ModLoader.current_config_changed.connect(_on_current_config_changed)
	ModLoaderLog.info("Ready!", AUTHORNAME_MODNAME_LOG_NAME)
	allCharacterNum= Players.charList.front() + 1
	characterNum = Players.Char.size()
	addEnemyToPool(AUTHORNAME_MODNAME_DIR,"star_shooter",0.9)
	addBossToQueue(AUTHORNAME_MODNAME_DIR,"starco",1)
	addBossToPool(AUTHORNAME_MODNAME_DIR,"starco",1.0,2)
	addItemsToPool(AUTHORNAME_MODNAME_DIR,testItem)
	addCustomCharacter(AUTHORNAME_MODNAME_DIR,myCharacter,charAbility)
	get_tree().node_added.connect(onNewNode)
	get_tree().node_removed.connect(onNoMoreNode)

func _disable():
	pass
#endregion

#region NODE HANDLING
func onNewNode(node):
	if node.is_in_group("boss_main"):
		if Global.main.bossQueue.size() == 0:
			Global.main.bossQueue = [
				Global.main.BossSpike, Global.main.BossSnake, Global.main.BossSlime,
				Global.main.BossSpike, Global.main.BossSnake, Global.main.BossSlime, Global.main.BossVirus,
			]
			if randf() < 0.33:
					Global.main.bossQueue.append(Global.main.BossOrb)
			for i in customBosses:
				if i.weight == 1.0:
					Global.main.bossQueue.append(i.type)
				elif randf() < i.weight:
					Global.main.bossQueue.append(i.type)
			Global.main.bossQueue.shuffle()
			bossQueueUpdated.emit(Global.main.bossQueue)
		bossSpawned.emit(node)
	elif node.is_in_group("enemy"):
		enemySpawned.emit(node)
	if node.get_script() != null:
		match node.get_script().get_path():
			"res://src/main/main.gd":
				var config = ModLoaderConfig.get_current_config(AUTHORNAME_MODNAME_DIR)
				oldBossesKilled = 0
				oldEnemiesKilled = 0
				onMain.emit(node)
				node.ready.connect(func():
					node.enemySelection += customEnemies
					for i in customBossQueue:
						node.bossQueue.insert(i.position,i.type)
					if config.data.debug:
						_debugWindow()
				)

func onNoMoreNode(node):
	if node.is_in_group("enemy"):
		if Stats.stats.totalEnemiesKilled > oldEnemiesKilled:
			enemyDied.emit(node)
			oldEnemiesKilled = Stats.stats.totalEnemiesKilled
	if node.is_in_group("boss_main"):
		if Stats.stats.totalBossesKilled > oldBossesKilled:
			oldBossesKilled = Stats.stats.totalBossesKilled
			bossDied.emit(node)
#endregion

#region ENEMIES AND BOSSES
func addEnemyToPool(modName:String,name:String,_weigth:float):
	customEnemies.append({type = load("res://mods-unpacked/"+modName+ "/extensions/src/enemy/" +name+"/"+name+".scn"),weight = _weigth,distribution = load("res://mods-unpacked/"+modName+ "/extensions/src/enemy/" +name+"/curve.tres"),waveWeight = 1.0,mod=modName})

func resetModEnemies(modName:String):
	for i in customEnemies:
		if i.mod == modName:
			customEnemies.remove_at(customEnemies.find(i))

func resetModBosses(modName:String):
	for i in customBosses:
		if i.mod == modName:
			customBosses.remove_at(customBosses.find(i))

func resetModBossQueue(modName:String):
	for i in customBossQueue:
		if i.mod == modName:
			customBossQueue.remove_at(customBossQueue.find(i))

func addBossToPool(modName:String,name:String,possibility:float = 1.0,amounts = 1):
	customBosses.append({type = load("res://mods-unpacked/"+modName+ "/extensions/src/enemy/" +name+"/"+name+".scn"),
	weight = possibility,
	size = amounts,
	mod=modName})

func addBossToQueue(modName:String,name:String,pos:int):
	customBossQueue.append({mod=modName,type= load("res://mods-unpacked/"+modName+ "/extensions/src/enemy/" +name+"/"+name+".scn"),position = pos})
#endregion

#region CUSTOM UPGRADES
func resetModItems(modName:String):
	for i in customUpgrades.keys():
		if customUpgrades[i].mod == modName:
			customUpgrades.erase(i)

func addItemsToPool(modName:String,upgrades:Dictionary):
	for i in upgrades.keys():
		upgrades[i].mod = modName
	customUpgrades.merge(upgrades)
#endregion

#region CUSTOM CHARACTERS
func addCustomCharacter(modName:String,data:Dictionary,ability:Dictionary):
	data.spawnRate = load("res://mods-unpacked/"+modName+"/extensions/src/character/"+data.internalName+"/curve.tres")
	var actual = {characterNum:{
	internalName = data.internalName,
	displayName = data.displayName,
	ability = characterNum,
	spawnRate = data.spawnRate,
	wallShrinkSpeed = data.wallShrinkSpeed,
	wallResistance = data.wallResistance,
	priceScale = data.priceScale,
	skins = data.skins,
	mod = modName,
	unlocked = true,
	}}
	var actualAbility={characterNum:{
	internalName = ability.internalName,
	name = ability.name,
	icon = ability.icon,
	priceType = 1,
	value = ability.value,
	price = ability.price,
	buy = ability.buy,
	description = ability.description,
	weight = ability.weight,
	mod = modName}
	}
	Players.charData.merge(actual)
	customCharAbility.merge(actualAbility)
	customCharacters.append({gameName =data.displayName,name = data.internalName,mod = modName,pos = characterNum,img = data.spritesExtension})
	Players.unlockedCharList.append(characterNum)
	Players.charList.append(characterNum)
	Players.charNames.merge({
		characterNum : data.internalName
	})
	Players.charDisplayNames.merge({
		characterNum : data.displayName
	})
	print(Players.charList)
	print(Players.unlockedCharList)
	print(characterNum)
	characterNum+=1
#endregion

#region CUSTOM WINDOWS
func addGameWindow(name:String,rad:int,size:Vector2,parent:Node = Global.gameArea,camera:bool=true,onTop:bool=true) -> Window:

	var window = Window.new()
	window.size = size
	window.position = Game.randomSpawnLocation(rad,300.0)
	window.unresizable = true
	window.always_on_top = Global.options.alwaysOnTop
	parent.add_child(window)
	if camera:
		var windowCamera = Camera2D.new()
		windowCamera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
		windowCamera.position = window.position
		windowCamera.set_script(load("res://modres/ommodutils/window_camera.gd"))
		window.add_child(windowCamera)
	Game.registerWindow(window, name)
	return window

static func addTitleWindow(name:String,pos:Vector2i,buttonArgs={"has"=false,"name"="button"}) -> Dictionary:
	var win = Global.title.addWindow(Vector2.INF, preload("res://src/title/panel/blank.tscn"), {name = name})
	if buttonArgs["has"] == true:
		var cont:Control = Control.new()
		cont.size = Vector2(360,300)
		cont.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cont.set_anchors_preset(Control.PRESET_FULL_RECT)
		win["window"].add_child(cont)
		var panel = PanelContainer.new()
		panel.set_anchors_preset(Control.PRESET_CENTER)
		panel.size = Vector2(360*0.5,54)
		panel.position = Vector2(-270,-185)
		panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
		cont.add_child(panel)
		var but = preload("res://src/ui/button/button.tscn").instantiate()
		but.text = buttonArgs["name"]
		panel.add_child(but)
		return {"window"=win,"button"=but}
	return {"window"=win}

#endregion

#region DEBUG
func _debugWindow():
	var debugWin = addGameWindow("debug",100,Vector2(300,300),Global.gameArea,false,true)
	var cont = Control.new()
	cont.layout_direction =Control.LAYOUT_DIRECTION_LTR
	cont.set_anchors_preset(Control.PRESET_FULL_RECT)
	cont.size = Vector2(300,300)
	cont.mouse_filter=Control.MOUSE_FILTER_PASS
	debugWin.add_child(cont)
	var holder = VBoxContainer.new()
	holder.layout_direction = Control.LAYOUT_DIRECTION_INHERITED
	holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.size = Vector2(300,300)
	holder.mouse_filter=Control.MOUSE_FILTER_PASS
	cont.add_child(holder)
	createDebugButton(holder,"Spawn next boss",func():
		Global.main.spawnBoss())
	createDebugButton(holder,"Give 1k coins",func():
		Global.coins = Global.coins + 1000)
	createDebugButton(holder,"Give 10k coins",func():
		Global.coins = Global.coins + 10000)
	createDebugButton(holder,"Spawn token",func():
		Utils.spawn(preload("res://src/element/power_token/powerToken.tscn"),Vector2(Global.player.global_position.x,Global.player.global_position.y),Global.main.coin_area))


func createDebugButton(cont:VBoxContainer,name:String,call:Callable):
	var uselessText = Label.new()
	uselessText.text = name
	cont.add_child(uselessText)
	var butt = Button.new()
	butt.text = name
	butt.button_down.connect(call)
	cont.add_child(butt)
#endregion

