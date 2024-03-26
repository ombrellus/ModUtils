extends Node

const AUTHORNAME_MODNAME_DIR := "ombrellus-modutils"
const AUTHORNAME_MODNAME_LOG_NAME := "ombrellus-modutils:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

signal enemyHit
signal onMain

var customEnemies:Array[Dictionary] = []

#region LOADING SHIT

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(AUTHORNAME_MODNAME_DIR)
	# Add extensions
	

func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")
	
	ModLoaderMod.install_script_extension("res://mods-unpacked/ombrellus-modutils/extensions/src/enemy/enemy.gd")


func _ready() -> void:
	install_script_extensions()
	ModLoaderLog.info("Ready!", AUTHORNAME_MODNAME_LOG_NAME)
	addEnemyToPool(AUTHORNAME_MODNAME_DIR,"star_shooter",0.9)
	get_tree().node_added.connect(onNewNode)
	enemyHit.connect(func(a,b):print("hitt"))

func _disable():
	pass
#endregion

#region NODE HANDLING
func onNewNode(node):
	if node.get_script() != null:
		match node.get_script().get_path():
			"res://src/main/main.gd":
				onMain.emit(node)
				node.ready.connect(func():
					node.enemySelection += customEnemies
				)
#endregion

#region ENEMIES AND BOSSES
func addEnemyToPool(modName:String,name:String,_weigth:float):
	customEnemies.append({type = load("res://mods-unpacked/"+modName+ "/extensions/src/enemy/" +name+"/"+name+".scn"),weight = _weigth,distribution = load("res://mods-unpacked/"+modName+ "/extensions/src/enemy/" +name+"/curve.tres"),waveWeight = 1.0,mod=modName})

func resetModEnemies(modName:String):
	for i in customEnemies:
		if i.mod == modName:
			customEnemies.remove_at(customEnemies.find(i))
#endregion


