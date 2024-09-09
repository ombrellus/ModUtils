extends Node
class_name OMModUtils

const AUTHORNAME_MODNAME_DIR := "ombrellus-modutils"
const AUTHORNAME_MODNAME_LOG_NAME := "ombrellus-modutils:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

signal enemyHit
signal bossQueueUpdated

var customUpgrades:Dictionary = {}
var customCurrencies:Dictionary = {}
var customCharAbility:Dictionary = {}

var customShopsData:Dictionary ={}

var thingier:Node

var customEnemies:Array[Dictionary] = []
var customBosses:Array[Dictionary] = []
var customBossQueue:Array[Dictionary] = []
var customCharacters:Array[Dictionary] =[]
var customGamemodes:Array[Dictionary]=[]
var customTitleWidnows:Array[Dictionary]=[]
var ambushes:Array[Dictionary]= []
var shops:Array[int] = [1]

var nextBossQueue:Array

var shopNum:int = 0
var characterNum:int
var currencyNum:int = 2
var allCharacterNum:int

var selectedGamemode:String = "none"
var gamemodeMod:String = "none"
var gaymodeCall:Callable = func():pass
var customGamemodeArgs:Dictionary = {timer=0.0,enemy=true,boss=true}

var customItemNames:Dictionary
var customItemIcons:Dictionary
var selectingGamemode:int = 0

var loadScn:bool = true
var loadRes:bool = true

var ambushTimer:int = 30

#region LOADING SHIT

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(AUTHORNAME_MODNAME_DIR)
	# Add extensions
	extensions_dir_path = mod_dir_path.path_join("extensions")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/title/panel/character.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/title/panel/newRun.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/title/panel/endless.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/player/player.gd")	
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/ui/stats/recordStats.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/ui/multiplayer/player_slot/player_slot.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/autoload/players.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/ui/coin_count/coinCount.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/ui/shop/shopItem.gd")	
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/ui/shop/shop.gd")	
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/title/panel/challenge/challengeSetupScreen.gd")
	

func install_script_extensions() -> void:
	
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/enemy/enemy.gd")
func _on_current_config_changed(config: ModConfig) -> void:
	# Check if the config of your mod has changed!
	if config.mod_id == AUTHORNAME_MODNAME_DIR:
		if Global.main != null and config.data.debug:
			_debugWindow()
		if config.data.scn:
			loadScn = config.data.scn
		if config.data.res:
			loadRes = config.data.scn
		if config.data.ambush:
			ambushTimer = config.data.ambush

func _ready() -> void:
	install_script_extensions()
	ModLoader.current_config_changed.connect(_on_current_config_changed)
	ModLoaderLog.info("Ready!", AUTHORNAME_MODNAME_LOG_NAME)
	allCharacterNum= Players.charList.front() + 1
	characterNum = Players.Char.size()
	Events.runStarted.connect(_loadMain)
	Events.bossSpawned.connect(_bossSpawnStuff)
	Events.titleReturn.connect(_titleThings)
	Events.runEnded.connect(_endThings)
	Events.restart.connect(_endThings)

func _endThings():
	resetItemVariables()

func _titleThings():
	resetItemVariables()
	selectedGamemode= "none"
	gamemodeMod= "none"
	gaymodeCall= func():pass
	customGamemodeArgs = {timer=0.0,enemy=true,boss=true}
	Utils.runLater(100,func():
		for i in customTitleWidnows:
			createTitleWindow(i.mod,i.windowName,i.windowIcon,i.color,i.splits)
		)



func _disable():
	pass
#endregion

#region DA FUNCTIONS
#endregion

#region NODE HANDLING
func shuffleBosses():
	if not nextBossQueue.is_empty():
		Global.main.bossQueue += nextBossQueue
		Global.main.bossQueue.shuffle()
		nextBossQueue.clear()
	if Global.main.bossQueue.size() != 0: return
	for i in customBosses:
		if i.weight == 1.0:
			nextBossQueue.append(i.type)
		elif randf() < i.weight:
			nextBossQueue.append(i.type)

func _bossSpawnStuff(boss:Node):
	shuffleBosses()

func _findItemIcon(entry:String,charInt:String,modName:String) -> Resource:
	var pathName:String = charInt+"_"+modName
	if customItemIcons.has(pathName):
		if customItemIcons[pathName].has(entry):
			return customItemIcons[pathName][entry]
	return null

func _findItemName(entry:String,charInt:String,modName:String) -> String:
	var pathName:String = charInt+"_"+modName
	print(pathName)
	if customItemNames.has(pathName):
		print("ok what")
		if customItemNames[pathName].has(entry):
			print(customItemNames[pathName][entry])
			return customItemNames[pathName][entry]
	return "OkIHopeNoOneUsesThisLineAsAnActualName"

func _loadMain():
	var config = ModLoaderConfig.get_current_config(AUTHORNAME_MODNAME_DIR)
	if customGamemodeArgs.timer != 0.0:
		Global.timedModeLimit = 60.0* customGamemodeArgs.timer
	else:
		Global.timedModeLimit = 60.0*20.0
	var ifYouThinkOfSomethingBetterDMme = load("res://mods-unpacked/ombrellus-modutils/extensions/src/repellenteDiNemici.tscn").instantiate()
	ifYouThinkOfSomethingBetterDMme.nemici = customGamemodeArgs.enemy
	ifYouThinkOfSomethingBetterDMme.boss = customGamemodeArgs.boss
	ifYouThinkOfSomethingBetterDMme.maxAmbush = ambushTimer
	Global.main.add_child(ifYouThinkOfSomethingBetterDMme)
	thingier = ifYouThinkOfSomethingBetterDMme
		
	Global.main.enemySelection += customEnemies
	for i in customBossQueue:
		Global.main.bossQueue.insert(i.position,i.type)
	ShopData.shopItemChoices.merge(customUpgrades)
	gaymodeCall.call()
	if config.data.debug:
		_debugWindow()

#endregion

#region CHECKS
#endregion

#region AMBUSHES
func addAmbushToPool(modName:String,name:String,chance:float, delay_minutes:float = 0.0):
	ambushes.append({type = _checkForScene("res://mods-unpacked/"+modName+ "/extensions/src/ambush/" +name+"/"+name),
	weight = chance,
	delay = delay_minutes,
	mod=modName})
#endregion

#region ENEMIES AND BOSSES
func addEnemyToPool(modName:String,name:String,_weigth:float):
	customEnemies.append({type = _checkForScene("res://mods-unpacked/"+modName+ "/extensions/src/enemy/" +name+"/"+name),weight = _weigth,distribution = _checkForResource("res://mods-unpacked/"+modName+ "/extensions/src/enemy/" +name+"/curve"),waveWeight = 1.0,mod=modName})

func addEnemyToPoolDirect(modName:String,name:String,_weigth:float):
	Global.main.enemySelection.append({type = _checkForScene("res://mods-unpacked/"+modName+ "/extensions/src/enemy/" +name+"/"+name),weight = _weigth,distribution = _checkForResource("res://mods-unpacked/"+modName+ "/extensions/src/enemy/" +name+"/curve"),waveWeight = 1.0,mod=modName})

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
	customBosses.append({type = _checkForScene("res://mods-unpacked/"+modName+ "/extensions/src/enemy/" +name+"/"+name),
	weight = possibility,
	size = amounts,
	mod=modName})

func addBossToQueue(modName:String,name:String,pos:int):
	customBossQueue.append({mod=modName,type= _checkForScene("res://mods-unpacked/"+modName+ "/extensions/src/enemy/" +name+"/"+name),position = pos})
#endregion

#region CUSTOM UPGRADES
func resetModItems(modName:String):
	for i in customUpgrades.keys():
		if customUpgrades[i].mod == modName:
			customUpgrades.erase(i)

func addItemsToPool(modName:String,upgrades:Dictionary, upgradesCurrency:int = -1):
	for i in upgrades.keys():
		upgrades[i].mod = modName
		upgrades[i].internalName = i
		if upgrades[i].priceType >= 2:
			upgrades[i]["ModUtils_currency"] = upgradesCurrency
			upgrades[i].priceType = 0
		if upgradesCurrency != 1:
			upgrades[i]["ModUtils_currency"] = upgradesCurrency
			upgrades[i].priceType = 0
		Global.manifestCounts[i] = 0
	customUpgrades.merge(upgrades)

func addItemsToCustomShop(modName:String,upgrades:Dictionary,currencyId:int, upgradesCurrency:int = -1):
	for i in upgrades.keys():
		upgrades[i].mod = modName
		upgrades[i].internalName = i
		if upgrades[i].priceType >= 2:
			upgrades[i]["ModUtils_currency"] = upgradesCurrency
			upgrades[i].priceType = 0
		if upgradesCurrency != 1:
			upgrades[i]["ModUtils_currency"] = upgradesCurrency
			upgrades[i].priceType = 0
		Global.manifestCounts[i] = 0
	customShopsData[currencyId]= upgrades.duplicate(true)
	print(customShopsData[currencyId])
	
func resetItemVariables():
	for i in customUpgrades:
		if customUpgrades[i].has("reset"):
			customUpgrades[i].reset.call()
	for i in customCurrencies:
		customCurrencies[i].reset.call()
	shops = [1]
	shopNum = 0
	
#endregion

#region CUSTOM CHARACTERS
func addCustomCharacter(modName:String,data:Dictionary,ability:Dictionary) -> int:
	data.spawnRate = _checkForResource("res://mods-unpacked/"+modName+"/extensions/src/character/"+data.internalName+"/curve")
	if not data.has("overwrite"): data["overwrite"] = false
	var actual = {characterNum:{
	internalName = data.internalName,
	displayName = data.displayName,
	ability = characterNum,
	ability_icon = data.ability_icon,
	ability_name = data.ability_name,
	useAbility = data.useAbility,
	abilityCooldown = data.abilityCooldown,
	spawnRate = data.spawnRate,
	baseWealth = data.baseWealth,
	wallShrinkSpeed = data.wallShrinkSpeed,
	wallResistance = data.wallResistance,
	priceScale = data.priceScale,
	statIcon = load("res://mods-unpacked/"+modName+"/extensions/src/character/"+data.internalName+"/top"+data.spritesExtension),
	icon = load("res://mods-unpacked/"+modName+"/extensions/src/character/"+data.internalName+"/top"+data.spritesExtension),
	icon_bg = load("res://mods-unpacked/"+modName+"/extensions/src/character/"+data.internalName+"/back"+data.spritesExtension),
	skins = data.skins,
	mod = modName,
	unlocked = true,
	}}
	if data.has("getColor"):
		actual[characterNum]["getColor"] = data.getColor
	if data.has("shopOverrides"):
		actual[characterNum]["shopOverrides"] = data.shopOverrides
	else:
		actual[characterNum]["shopOverrides"] = {}
	customItemIcons[data.internalName+"_"+modName] = {}
	customItemNames[data.internalName+"_"+modName] = {}
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
	_weight = ability._weight,
	mod = modName}
	}
	Players.charData.merge(actual)
	customCharAbility.merge(actualAbility)
	ShopData.abilityChoices.merge(actualAbility)
	customCharacters.append({gameName =data.displayName,icon =actual[characterNum].icon,icon_bg =actual[characterNum].icon_bg ,name = data.internalName,mod = modName,pos = characterNum,img = data.spritesExtension, overwrite = data.overwrite})
	Players.charList.append(characterNum)
	Players.charNames.merge({
		characterNum : data.internalName
	})
	Players.charDisplayNames.merge({
		characterNum : data.displayName
	})
	Players.updateUnlocks()
	characterNum+=1
	return characterNum - 1

func addCharacterItemIcon(modName:String,charName:String,itemName:String,iconPath:String):
	customItemIcons[charName+"_"+modName][itemName] = load(iconPath)

func addCharacterItemName(modName:String,charName:String,itemName:String,newName:String):
	customItemNames[charName+"_"+modName][itemName] = newName

func getCharacterId(modName:String,charName:String) -> int:
	for c in customCharacters:
		if c.name == charName and c.mod == modName:
			return c.pos
	return -1
#endregion

#region CUSTOM GAMEMODES
func addCustomGamemode(modName:String,modeName:String,modeIconPath:String,iconColor:Color,spawnEnemy:bool = true,spawnBosses:bool = true,timed:float=0.0,extraReadyCall:Callable=func():pass):
	customGamemodes.append({mod=modName,name=modeName,call=extraReadyCall,enemy=spawnEnemy,boss=spawnBosses,timer=timed,icon = load(modeIconPath),color = iconColor})

func checkCustomGamemode(modName:String,gamemode:String)->bool:
	if gamemodeMod == modName and gamemode == selectedGamemode:
		return true
	return false

#endregion

#region CUSTOM CURRENCY
func addCustomCurrency(modName:String,data:Dictionary) -> int:
	customCurrencies[currencyNum] = data.duplicate(true)
	customCurrencies[currencyNum]["mod"] = modName
	currencyNum +=1
	return currencyNum - 1

func getCurrencyId(modName:String, name:String) -> int:
	for c in customCurrencies:
		if customCurrencies[c]["mod"] == modName and customCurrencies[c]["name"] == name:
			return c
	return -1
#endregion

#region CUSTOM WINDOWS
func addGameWindow(name:String,spawnPos:Vector2,size:Vector2,parent:Node = Global.gameArea,camera:bool=true,z_index:int = 10,no_drag:bool=false) -> Window:

	var window = Window.new()
	window.size = size
	window.position = spawnPos
	window.unresizable = no_drag
	window.set_meta("z_index",z_index)
	window.set_meta("no_drag",no_drag)
	window.always_on_top = Global.options.alwaysOnTop
	parent.add_child(window)
	if camera:
		var windowCamera = Camera2D.new()
		windowCamera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
		windowCamera.position = window.position
		windowCamera.set_script(load("res://mods-unpacked/ombrellus-modutils/extensions/src/ui/windowCamera.gd"))
		window.add_child(windowCamera)
	Game.registerWindow(window, name)
	Game.reorderWindows()
	return window

func addTitleWindow(modName:String,name:String,icon:Texture2D,iconColor:Color,splitWindows:Array):
	customTitleWidnows.append({mod=modName,windowName=name,windowIcon=icon,color=iconColor,splits=splitWindows})

func createTitleWindow(modName:String,name:String,icon:Texture2D,iconColor:Color,splitWindows:Array) -> TitleWindow:
	var win = Global.title.addWindow(Vector2.INF, load("res://mods-unpacked/ombrellus-modutils/extensions/src/title/panel/titleUtil.tscn"), {name = name})
	var actualWin = win.window
	actualWin.bg.texture = icon
	actualWin.bg.modulate = iconColor
	actualWin.button.text = name
	actualWin.splitWindows = splitWindows
	actualWin.button.update()
	return actualWin

#endregion

#region DEBUG
func _debugWindow():
	var debugWin = addGameWindow("debug",Game.randomSpawnLocation(400,200),Vector2(300,300),Global.gameArea,true,30,false)
	var canvas = CanvasLayer.new()
	var cont = Control.new()
	cont.layout_direction =Control.LAYOUT_DIRECTION_LTR
	cont.set_anchors_preset(Control.PRESET_TOP_LEFT)
	cont.size = Vector2(300,300)
	cont.mouse_filter=Control.MOUSE_FILTER_PASS
	canvas.add_child(cont)
	debugWin.add_child(canvas)
	var WHAT = ScrollContainer.new()
	WHAT.layout_direction = Control.LAYOUT_DIRECTION_INHERITED
	WHAT.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	WHAT.set_anchors_preset(Control.PRESET_FULL_RECT)
	WHAT.size = Vector2(300,300)
	cont.add_child(WHAT)
	var holder = VBoxContainer.new()
	holder.layout_direction = Control.LAYOUT_DIRECTION_INHERITED
	holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.size = Vector2(300,300)
	holder.mouse_filter=Control.MOUSE_FILTER_PASS
	WHAT.add_child(holder)
	createDebugButton(holder,"Spawn next boss",func():
		Global.main.spawnBoss())
	createDebugButton(holder,"Spawn next enemy",func():
		Global.main.spawnTimer = 0)
	createDebugButton(holder,"Spawn entity",func():
		_createEntityWindow())
	createDebugButton(holder,"Give 10k coins",func():
		Global.coins = Global.coins + 10000)
	createDebugButton(holder,"Spawn token",func():
		Utils.spawn(preload("res://src/element/power_token/powerToken.tscn"),Vector2(Global.player.global_position.x,Global.player.global_position.y),Global.main.coin_area))
	createDebugButton(holder,"Refill ability",func():
		Global.abilityCooldown = 0
		Global.abilityTimer = 0)
	createDebugButton(holder,"Time skip",func():
		Global.gameTime+= 1*60.0)
	createDebugButton(holder,"Spawn Ambush",func():
		if not thingier == null:
			thingier.spawnAmbush())
	createDebugButton(holder,"Spawn Mimic",func():
		Utils.spawn(preload("res://src/enemy/tokenMimic/tokenMimic.tscn"),Global.main.getOutsidePosition(),Global.gameArea))

func createDebugButton(cont:VBoxContainer,name:String,call:Callable):
	var butt = Button.new()
	butt.text = name
	butt.button_down.connect(call)
	cont.add_child(butt)

func _createEntityWindow():
	var debugWin = addGameWindow("Entity select",Game.randomSpawnLocation(400,200),Vector2(360,360),Global.gameArea,true,30,false)
	debugWin.close_requested.connect(func():debugWin.queue_free())
	var cont:Control = preload("res://mods-unpacked/ombrellus-modutils/extensions/src/chooser/entity_chooser.tscn").instantiate()
	var canvas = CanvasLayer.new()
	canvas.add_child(cont)
	debugWin.add_child(canvas)
	var grid:GridContainer = cont.get_child(0)
	_addEntityButton("Spiker",Global.main.BossSpike,grid)
	_addEntityButton("Wyrm",Global.main.BossSnake,grid)
	_addEntityButton("Slime",Global.main.BossSlime,grid)
	_addEntityButton("Smiley",Global.main.BossVirus,grid)
	_addEntityButton("Orb array",Global.main.BossOrb,grid)
	_addEntityButton("Miasma",Global.main.BossGermSource,grid)
	var enemyNames:=["Triangle","Square","Circle","Hexagon","Heptagon","Splitter","Sweeper","Tunneller","Arrow"]
	for i in Global.main.enemySelection:
		var name:String = "Mod enemy"
		if not enemyNames.is_empty():
			name = enemyNames.pop_front()
		_addEntityButton(name,i.type,grid)
func _addEntityButton(name:String,scene:PackedScene,cont:GridContainer):
	var entityButton:Button = Button.new()
	entityButton.text = name
	entityButton.custom_minimum_size = Vector2(80,50)
	entityButton.button_up.connect(_spawnEntity.bind(scene,cont.get_parent().get_child(1)))
	cont.add_child(entityButton)

func _spawnEntity(entity:PackedScene,option:OptionButton):
	var posRand:Vector2 = Game.randomSpawnLocation(400, 300.0)
	match option.selected:
		0:
			Utils.spawn(entity, Game.randomPlayer().position, Global.gameArea)
		1:
			Utils.spawn(entity, Game.randomPlayer().position - Vector2(0,100), Global.gameArea)
		3:
			Utils.spawn(entity, posRand, Global.gameArea)

func _checkForScene(path:String) -> PackedScene:
	if ResourceLoader.exists(path+".tscn"):
		return load(path+".tscn")
	elif loadScn:
		return load(path+".scn")
	else:
		print_debug("Could not find any file with the path " + path)
		return null

func _checkForResource(path:String) -> Resource:
	print(path+".tres")
	print(ResourceLoader.exists(path+".tres"))
	if ResourceLoader.exists(path+".tres"):
		return load(path+".tres")
	elif loadRes:return load(path+".res")
	else:
		print_debug("Could not find any file with the path " + path)
		return null

func _errorNotFile(path:String):
	print_debug("Could not find any file with the path " + path)
#endregion

