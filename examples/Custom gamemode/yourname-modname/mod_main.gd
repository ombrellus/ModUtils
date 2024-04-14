extends Node

const AUTHORNAME_MODNAME_DIR := "yourname-modname" # Name of the directory that this file is in
const AUTHORNAME_MODNAME_LOG_NAME := "yourname-modname:Main" # Full ID of the mod (AuthorName-ModName)

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

var ballTimer:float = 0.5

@onready var modUtils = get_node("/root/ModLoader/ombrellus-modutils")

func _init() -> void:
	ModLoaderLog.info("Init", AUTHORNAME_MODNAME_LOG_NAME)
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(AUTHORNAME_MODNAME_DIR)
	install_script_extensions()


func install_script_extensions() -> void:
	# ! any script extensions should go in this directory, and should follow the same directory structure as vanilla
	extensions_dir_path = mod_dir_path.path_join("extensions")


func _ready() -> void:
	ModLoaderLog.info("Ready", AUTHORNAME_MODNAME_LOG_NAME)
	modUtils.addCustomGamemode(AUTHORNAME_MODNAME_DIR,"coolmode","res://mods-unpacked/yourname-modname/coolmode.svg",false,true,5.0,func():print("cool gamemode"))

func _process(delta):
	if Global.main != null and modUtils.checkCustomGamemode(AUTHORNAME_MODNAME_DIR,"coolmode"):
		ballTimer-=delta
		if ballTimer <= 0:
			Utils.spawn(preload("res://src/enemy/circle/circle.tscn"),Global.main.getOutsidePosition(),Global.gameArea)
			ballTimer = 0.5
