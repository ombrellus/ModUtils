extends Node

const AUTHORNAME_MODNAME_DIR := "ombrellus-modutils"
const AUTHORNAME_MODNAME_LOG_NAME := "ombrellus-modutils:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

var utilsname = "ommodutils"
	
var customUpgrades:Dictionary = {}
var customCharAbility:Dictionary = {}
var customOptions:Array[Dictionary] = []
var customBosses:Array[Dictionary] = []
var customBossQueue:Array[Dictionary] = []
var customEnemies:Array[Dictionary] = []
var customCharacters:Array[Dictionary] =[]
var customGamemodes:Array[Dictionary]
var customTabs:Array[String] =[]

var selectedGamemode:String = "none"
var gamemodeMod:String = "none"
var gaymodeCall:Callable = func():pass
var customGamemodeArgs:Dictionary = {timer=0.0,enemy=true,boss=true}

var selectingGamemode:int = 0

var optionPage:Window
var gameScene:Node
var gameUi:Control
var characterNum:int

var oldBossesKilled = 0
var oldEnemiesKilled = 0
var restarting:bool = false

#region CUSTOM ENEMIES AND BOSSES

func addEnemyToPool(modName:String,name:String,_weigth:float):
	customEnemies.append({type = load("res://mods-unpacked/"+modName+ "/src/enemies/" +name+"/"+name+".tscn"),weight = _weigth,distribution = load("res://mods-unpacked/"+modName+ "/src/enemies/" +name+"/curve.tres"),waveWeight = 1.0,mod=modName})

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
	customBosses.append({type = load("res://modres/"+modName+ "/bosses/" +name+"/"+name+".scn"),
	weight = possibility,
	size = amounts,
	mod=modName})

func addBossToQueue(modName:String,name:String,pos:int):
	customBossQueue.append({mod=modName,type= load("res://modres/"+modName+ "/bosses/" +name+"/"+name+".scn"),position = pos})

#endregion

#region CUSTOM UPGRADES
func resetModUpgrades(modName:String):
	for i in customUpgrades.keys():
		if customUpgrades[i].mod == modName:
			customUpgrades.erase(i)

func addUpgradesToPool(modName:String,upgrades:Dictionary):
	for i in upgrades.keys():
		upgrades[i].mod = modName
	customUpgrades.merge(upgrades)

static func addDirectUpgradesToPool(upgrades:Dictionary,shop:Window):
	shop.shopItemChoices.merge(upgrades)
#endregion

#region CUSTOM GAMEMODES
func addCustomGamemode(modName:String,modeName:String,spawnEnemy:bool = true,spawnBosses:bool = true,timed:float=0.0,extraReadyCall:Callable=func():pass):
	customGamemodes.append({mod=modName,name=modeName,call=extraReadyCall,enemy=spawnEnemy,boss=spawnBosses,timer=timed})
#endregion

#region CUSTOM CHARACTERS
func addCustomCharacter(modName:String,data:Dictionary,ability:Dictionary):
	data.spawnRate = load("res://modres/"+modName+"/characters/"+data.internalName+"/curve.tres")
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
	characterNum+=1
#endregion

#region CUSTOM OPTIONS
#POSSIBLE PAGES:
#general
#gameplay
#display
#windows
#controls (kinda)
#multiplayer
#unlocks (kinda)
func addCustomToggleOption(modName:String,optionMenuName:String,page:String, optionInternal:String,startsEnabled:bool=false,tip:String=".", extraActivationCallable:Callable=func(val):pass):
	customOptions.append({mod = modName,tooltip=tip,optionName = optionMenuName,menuPage = page,option = optionInternal, type = "toggle",enabled=startsEnabled,extraCallable=extraActivationCallable})
	print("FUCK YEAAAAAAA")

func addCustomToggleOptionDirectToMenu(modName:String,optionMenuName:String,page:String, optionInternal:String,startsEnabled:bool=false,tip:String=".", extraActivationCallable:Callable=func(val):pass):
	#customOptions.append({mod = modName, optionName = optionMenuName,menuPage = page,option = optionInternal, type = "toggle",enabled=startsEnabled,extraCallable=extraActivationCallable})
	var option_class = load("res://src/ui/options/option.gd")
	var option_list
	var option_tabs = optionPage.find_child("CanvasLayer").find_child("Control").find_child("Container").find_child("VBoxContainer").find_child("tabContainer").get_children()
	for s in option_tabs:
		if s.name == page:
			option_list = s
	var option = load("res://src/ui/options/option.tscn").instantiate()
	option.type = option_class.Type.toggle
	if tip == ".":
		option.tooltip = modName
	else:
		option.tooltip = tip
	option.text = optionMenuName
	option.option = optionInternal
	
	var toggle:CheckButton = option.get_node("HBoxContainer/toggleButton").get_node("CheckButton")
	toggle.button_pressed = startsEnabled
	if Global.options.has(optionInternal):
		toggle.button_pressed = Global.options[optionInternal]
	else:
		toggle.button_pressed = startsEnabled
		Global.options[optionInternal] = startsEnabled
	
	toggle.toggled.connect(func(val):
		Global.options[optionInternal] = val
	)
	toggle.toggled.connect(extraActivationCallable)
	option_list.get_child(0).add_child.call_deferred(option)

func addCustomSliderOption(modName:String,optionMenuName:String,page:String, optionInternal:String,sliderSettings:Vector4= Vector4(0,50,25,1),tip:String=".",extraActivationCallable:Callable=func(val):pass):
	customOptions.append({mod = modName,tooltip=tip, optionName = optionMenuName,menuPage = page,option = optionInternal, type = "slider",slider=sliderSettings,extraCallable=extraActivationCallable})

func addCustomSliderOptionDirectToMenu(modName:String,optionMenuName:String,page:String, optionInternal:String,sliderSettings:Vector4 = Vector4(0,50,25,1),tip:String="." ,extraActivationCallable:Callable=func(val):pass):
	#customOptions.append({mod = modName, optionName = optionMenuName,menuPage = page,option = optionInternal, type = "toggle",enabled=startsEnabled,extraCallable=extraActivationCallable})
	var option_class = load("res://src/ui/options/option.gd")
	var option_list
	var option_tabs = optionPage.find_child("CanvasLayer").find_child("Control").find_child("Container").find_child("VBoxContainer").find_child("tabContainer").get_children()
	for s in option_tabs:
		if s.name == page:
			option_list = s
	var option = load("res://src/ui/options/option.tscn").instantiate()
	option.type = option_class.Type.slider
	if tip == ".":
		option.tooltip = modName
	else:
		option.tooltip = tip
	option.text = optionMenuName
	option.option = optionInternal
	
	var slider:Slider = option.get_node("HBoxContainer/Slider").get_node("HBoxContainer/Slider")
	slider.min_value = sliderSettings.x
	slider.max_value = sliderSettings.y
	slider.step = sliderSettings.w
	if Global.options.has(optionInternal):
		slider.value = Global.options[optionInternal]
	else:
		slider.value = sliderSettings.z
		Global.options[optionInternal] = sliderSettings.z
	
	slider.value_changed.connect(func(val):
		Global.options[optionInternal] = val
	)
	slider.value_changed.connect(extraActivationCallable)
	option_list.get_child(0).add_child.call_deferred(option)

func addCustomChoiceOption(modName:String,optionMenuName:String,page:String, optionInternal:String,choices:Dictionary, defaultChoice:String,tip:String=".",extraActivationCallable:Callable=func(val):pass):
	customOptions.append({mod = modName,tooltip=tip, optionName = optionMenuName,menuPage = page,option = optionInternal, type = "choice",choicesOption=choices,default=defaultChoice,extraCallable=extraActivationCallable})

func addCustomChoiceOptionDirectToMenu(modName:String,optionMenuName:String,page:String, optionInternal:String,choices:Dictionary, defaultChoice:String,tip:String=".",extraActivationCallable:Callable=func(val):pass):
	#customOptions.append({mod = modName, optionName = optionMenuName,menuPage = page,option = optionInternal, type = "toggle",enabled=startsEnabled,extraCallable=extraActivationCallable})
	var option_class = load("res://src/ui/options/option.gd")
	var option_list
	var option_tabs = optionPage.find_child("CanvasLayer").find_child("Control").find_child("Container").find_child("VBoxContainer").find_child("tabContainer").get_children()
	for s in option_tabs:
		if s.name == page:
			option_list = s
	var option = load("res://src/ui/options/option.tscn").instantiate()
	option.type = option_class.Type.choice
	if tip == ".":
		option.tooltip = modName
	else:
		option.tooltip = tip
	option.text = optionMenuName
	option.option = optionInternal
	
	Global.optionChoices[optionInternal] = choices
	
	if not Global.options.has(optionInternal):
		Global.options[optionInternal] = defaultChoice
	
	var choice:CheckButton = option.get_node("HBoxContainer/choiceButton")
	choice.item_selected.connect(func(val):
		Global.options[optionInternal] = val
	)
	choice.item_selected.connect(extraActivationCallable)
	option_list.get_child(0).add_child.call_deferred(option)

func addCustomOptionTab(name:String):
	customTabs.append(name)
func addCustomOptionTabDirect(name:String):
	var tab = MarginContainer.new()
	tab.custom_minimum_size= Vector2(800,0)
	tab.set_anchors_preset(Control.PRESET_CENTER_TOP)
	tab.size = Vector2(940,666)
	tab.position = Vector2(-290,0)
	tab.size_flags_horizontal =Control.SIZE_EXPAND_FILL
	tab.size_flags_vertical =Control.SIZE_EXPAND_FILL
	tab.add_theme_constant_override("margin_top",60)
	tab.add_theme_constant_override("margin_bottom",60)
	tab.name = name
	optionPage.find_child("CanvasLayer").find_child("Control").find_child("Container").find_child("VBoxContainer").find_child("tabContainer").add_child(tab)
	var box = VBoxContainer.new()
	box.custom_minimum_size = Vector2(940,0)
	box.size_flags_horizontal =Control.SIZE_SHRINK_CENTER
	box.size_flags_vertical =Control.SIZE_FILL
	box.add_theme_constant_override("separation",40)
	box.name = "VBoxContainer"
	tab.add_child(box)
	optionPage.tabCount += 1

#endregion
	
#region CHECKS

func checkCustomGamemode(modName:String,gamemode:String)->bool:
	if gamemodeMod == modName and gamemode == selectedGamemode:
		return true
	return false

static func isTitle(node:Node) -> bool:
		if node.get_script() != null:
			if node.get_script().get_path() == "res://src/title/title.gd":
				return true
		return false

static func isMain(node:Node) -> bool:
	if node.get_script() != null:
		if node.get_script().get_path() == "res://src/main/main.gd":
			return true
	return false
static func isShop(node:Node) -> bool:
	if node.get_script() != null:
		if node.get_script().get_path() == "res://src/ui/shop/shop.gd":
			return true
	return false
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

signal onTitle
signal onMain
signal onShop
signal onOptions
signal onEscape

signal enemySpawned
signal coinSpawned
signal bossSpawned
signal tokenSpawned

signal enemyHit
signal enemyDied
signal bossDied

signal itemBought
signal upgradeBought

signal bossQueueUpdated

func _ready():
	#var test = ProjectSettings.load_resource_pack(gumm.get_full_path("mod://pack.pck"))
	print("YEAH")
	get_tree().node_added.connect(on_new_node)
	get_tree().node_removed.connect(on_kill_node)
	characterNum = Players.Char.size()
	addEnemyToPool(AUTHORNAME_MODNAME_DIR,"star_shooter",0.9)
	#addCustomToggleOption(utilsname,"In-game debug menu","display","OMmod_utils_debug_menu",false,"Opens debug menu when in game",func(val):pass)

#region NEW NODE HANDLING
func on_new_node(node:Node):
	if isTitle(node):
		restarting =false
		selectedGamemode= "none"
		gamemodeMod= "none"
		gaymodeCall= func():pass
		customGamemodeArgs = {timer=0.0,enemy=true,boss=true}
		onTitle.emit(node)
	if isMain(node):
		oldBossesKilled = 0
		oldEnemiesKilled = 0
		gameScene = node
		restarting =false
		onMain.emit(node)
		node.ready.connect(func():
			if customGamemodeArgs.timer != 0.0:
				Global.timedModeLimit = 60.0* customGamemodeArgs.timer
			else:
				Global.timedModeLimit = 60.0*20.0
				node.enemySelection += customEnemies
				for i in customBossQueue:
					gameScene.bossQueue.insert(i.position,i.type)
				if Global.options["OMmod_utils_debug_menu"]:
					_debugWindow()
				gameUi = node.game_ui
				node.game_ui.tree_exiting.connect(func():
					restarting = true)
				gaymodeCall.call()
			)
		if isShop(node):
			node.abilityChoices.merge(customCharAbility)
			node.ready.connect(func():
				node.shopItemChoices.merge(customUpgrades))
			onShop.emit(node)
		if node.is_in_group("enemy"):
			enemySpawned.emit(node)
		if node.is_in_group("token"):
			tokenSpawned.emit(node)
		if node.is_in_group("boss_main"):
			if gameScene.bossQueue.size() == 0:
				gameScene.bossQueue = [
					gameScene.BossSpike, gameScene.BossSnake, gameScene.BossSlime,
					gameScene.BossSpike, gameScene.BossSnake, gameScene.BossSlime, gameScene.BossVirus,
				]
				if randf() < 0.33:
					gameScene.bossQueue.append(gameScene.BossOrb)
				for i in customBosses:
					if i.weight == 1.0:
						gameScene.bossQueue.append(i.type)
					elif randf() < i.weight:
						gameScene.bossQueue.append(i.type)
				gameScene.bossQueue.shuffle()
				bossQueueUpdated.emit(gameScene.bossQueue)
			bossSpawned.emit(node)
		if node.is_in_group("coin"):
			coinSpawned.emit(node)
		if node.get_script() != null:
			match node.get_script().get_path():
				"res://src/ui/options/options.gd":
					onOptions.emit(node)
					optionPage = node
					optionPage.ready.connect(func():
						for i in customTabs:
							addCustomOptionTabDirect(i)
						for i in customOptions:
							if i.type == "toggle":
								
								#customOptions.append({mod = modName, optionName = optionMenuName,menuPage = page,option = optionInternal, type = "toggle",enabled=startsEnabled,extraCallable=extraActivationCallable})
								addCustomToggleOptionDirectToMenu(i.mod,i.optionName,i.menuPage,i.option,i.enabled,i.tooltip,i.extraCallable)
							elif i.type == "slider":
								
								#customOptions.append({mod = modName, optionName = optionMenuName,menuPage = page,option = optionInternal, type = "slider",slider=sliderSettings,extraCallable=extraActivationCallable})
								addCustomSliderOptionDirectToMenu(i.mod,i.optionName,i.menuPage,i.option,i.slider,i.tooltip,i.extraCallable)
							elif i.type == "choice":
								
								#customOptions.append({mod = modName, optionName = optionMenuName,menuPage = page,option = optionInternal, type = "choice",choicesOption=choices,default=defaultChoice,extraCallable=extraActivationCallable})
								addCustomChoiceOptionDirectToMenu(i.mod,i.optionName,i.menuPage,i.option,i.choicesOption,i.default,i.tooltip,i.extraCallable)
								)
				"res://src/title/panel/endless.gd":
					node.ready.connect(func():
						node.button.click.connect(func():
							Global.timedModeLimit = 60.0 * 20.0
							selectedGamemode= "none"
							gamemodeMod="none"
							gaymodeCall = func():pass
							customGamemodeArgs = {timer=0.0,enemy=true,boss=true}
						)
					)
				"res://src/title/panel/timed.gd":
					node.ready.connect(func():
						node.button.click.connect(func():
							Global.timedModeLimit = 60.0 * 20.0
							selectedGamemode= "none"
							gamemodeMod="none"
							gaymodeCall = func():pass
							customGamemodeArgs = {timer=0.0,enemy=true,boss=true}
						)
					)
				"res://src/title/panel/newRun.gd":
					node.ready.connect(func():
						var games:Array[PackedScene]
						for i in node.button.click.get_connections():
							node.button.click.disconnect(i.callable)
						for i in customGamemodes:
							games.append(load("res://modres/ommodutils/gamemode.scn"))
						node.button.click.connect(func():
							selectingGamemode = 0
							Global.title.switch(self)
							Global.title.split(node, [preload("res://src/title/panel/timed.tscn"),preload("res://src/title/panel/endless.tscn")]+games)
						)
						print(node.button.click.get_connections())
					)
				"res://modres/ommodutils/gamemode.gd":
					print("im alive")
					node.ready.connect(func():
						var curMode = customGamemodes[selectingGamemode]
						print(curMode)
						selectingGamemode+=1
						node.gamemode = curMode
						node.button.text = node.gamemode.name
						node.button.update()
						node.button.click.connect(func():
							if node.gamemode.timer != 0.0:
								Players.timedMode = true
								Global.timedModeLimit = 60.0 * node.gamemode.timer
							else:
								Players.timedMode = false
								Global.timedModeLimit = 60.0 * 20.0
							selectedGamemode= node.gamemode.name
							gamemodeMod=node.gamemode.mod
							gaymodeCall = node.gamemode.call
							customGamemodeArgs = {timer=node.gamemode.timer,enemy=node.gamemode.enemy,boss=node.gamemode.boss}
							)
					)
				"res://src/title/panel/character.gd":
					for x in customCharacters:
						if x.pos == Players.unlockedCharList[Global.title._charId]:
							node.set_script(load("res://modres/ommodutils/custom_character_select.gd"))
							node.charName = x.name
							node.mod = x.mod
							node.charVisualName = x.gameName
							node.ext = x.img
				"res://src/player/player.gd":
					for x in customCharacters:
						if x.pos == Players.details[0].char:
							node.behavior = Utils.spawn(load("res://modres/"+Players.details[0].charMod+"/characters/"+Players.details[0].charInt+"/"+Players.details[0].charInt+".scn"), Vector2.ZERO, node)
				"res://src/ui/upgrade_shop/upgradeShopItem.gd":
					node.tree_exiting.connect(func():
						if node.bought:
							upgradeBought.emit(node.entry)
						)
				"res://src/ui/shop/shopItem.gd":
					node.tree_exiting.connect(func():
						if node.bought:
							match node.entry.priceType:
								0:
									itemBought.emit(node.entry)
								1:
									upgradeBought.emit(node.entry)
						)
				"res://src/ui/escape.gd":
					onEscape.emit()
				"res://src/ui/closeConfirm.gd":
					node.quit.click.connect(func():
						restarting = true
						print("dead"))

func _process(delta):
	if gameScene !=null:
		if not customGamemodeArgs.enemy:
			gameScene.spawnTimer = 10
		if not customGamemodeArgs.boss:
			gameScene.bossTimer = 10

func _init():
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/src/extensions/enemy.gd")

func on_kill_node(node:Node):
	if node.is_in_group("enemy"):
		if Stats.stats.totalEnemiesKilled > oldEnemiesKilled:
			enemyDied.emit(node)
			oldEnemiesKilled = Stats.stats.totalEnemiesKilled
	if node.is_in_group("boss_main"):
		if Stats.stats.totalBossesKilled > oldBossesKilled:
			oldBossesKilled = Stats.stats.totalBossesKilled
			bossDied.emit(node)
	
	#endregion
	
	#region DEBUG
func _debugWindow():
	var debugWin = addGameWindow("debug",100,Vector2(300,300),gameScene.game_area,false,true)
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
		gameScene.spawnBoss())
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
