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
var customCharAbility:Dictionary = {}

var customEnemies:Array[Dictionary] = []
var customBosses:Array[Dictionary] = []
var customBossQueue:Array[Dictionary] = []
var customCharacters:Array[Dictionary] =[]

var characterNum:int
var allCharacterNum:int

var loadScn:bool = true
var loadRes:bool = true

#region LOADING SHIT

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(AUTHORNAME_MODNAME_DIR)
	# Add extensions
	extensions_dir_path = mod_dir_path.path_join("extensions")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/title/panel/character.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/ui/stats/recordStats.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/ui/multiplayer/player_slot/player_slot.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/autoload/players.gd")
	

func install_script_extensions() -> void:
	
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/enemy/enemy.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/player/player.gd")

func _on_current_config_changed(config: ModConfig) -> void:
	# Check if the config of your mod has changed!
	if config.mod_id == AUTHORNAME_MODNAME_DIR:
		if Global.main != null and config.data.debug:
			_debugWindow()
		if config.data.scn:
			loadScn = config.data.scn
		if config.data.res:
			loadRes = config.data.scn

func _ready() -> void:
	install_script_extensions()
	ModLoader.current_config_changed.connect(_on_current_config_changed)
	ModLoaderLog.info("Ready!", AUTHORNAME_MODNAME_LOG_NAME)
	allCharacterNum= Players.charList.front() + 1
	characterNum = Players.Char.size()
	Events.runStarted.connect(_loadMain)
	Events.bossSpawned.connect(_bossSpawnStuff)

func _disable():
	pass
#endregion

#region NODE HANDLING
func _bossSpawnStuff(boss:Node):
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

func _loadMain():
	var config = ModLoaderConfig.get_current_config(AUTHORNAME_MODNAME_DIR)
	Global.main.enemySelection += customEnemies
	for i in customBossQueue:
		Global.main.bossQueue.insert(i.position,i.type)
	ShopData.abilityChoices.merge(customCharAbility)
	ShopData.shopItemChoices.merge(customUpgrades)
	if config.data.debug:
		_debugWindow()

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

func addItemsToPool(modName:String,upgrades:Dictionary):
	for i in upgrades.keys():
		upgrades[i].mod = modName
	customUpgrades.merge(upgrades)
#endregion

#region CUSTOM CHARACTERS
func addCustomCharacter(modName:String,data:Dictionary,ability:Dictionary):
	data.spawnRate = _checkForResource("res://mods-unpacked/"+modName+"/extensions/src/character/"+data.internalName+"/curve")
	var actual = {characterNum:{
	internalName = data.internalName,
	displayName = data.displayName,
	ability = characterNum,
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
	customCharacters.append({gameName =data.displayName,icon =actual[characterNum].icon,icon_bg =actual[characterNum].icon_bg ,name = data.internalName,mod = modName,pos = characterNum,img = data.spritesExtension})
	Players.charList.append(characterNum)
	Players.charNames.merge({
		characterNum : data.internalName
	})
	Players.charDisplayNames.merge({
		characterNum : data.displayName
	})
	Players.updateUnlocks()
	characterNum+=1
#endregion

#region CUSTOM WINDOWS
static func addGameWindow(name:String,spawnPos:Vector2,size:Vector2,parent:Node = Global.gameArea,camera:bool=true,z_index:int = 10,no_drag:bool=false) -> Window:

	var window = Window.new()
	window.size = size
	window.position = spawnPos
	window.unresizable = true
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
	var debugWin = addGameWindow("debug",Game.randomSpawnLocation(400,200),Vector2(300,300),Global.gameArea,false,30,false)
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

func _checkForScene(path:String) -> PackedScene:
	if ResourceLoader.exists(path+".tscn"):
		return load(path+".tscn")
	elif loadScn:return load(path+".scn")
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

