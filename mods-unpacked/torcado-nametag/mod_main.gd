extends Node

const AUTHORNAME_MODNAME_DIR := "torcado-nametag"
const AUTHORNAME_MODNAME_LOG_NAME := "torcado-nametag:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

var Global:Node

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(AUTHORNAME_MODNAME_DIR)
	# Add extensions
	install_script_extensions()
	
	# Add global script
	Global = load("res://mods-unpacked/torcado-nametag/global.gd").new()
	Global.name = "Global"
	add_child(Global)
	

func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")
	
	ModLoaderMod.install_script_extension("res://mods-unpacked/torcado-nametag/extensions/src/player/player.gd")

func _on_current_config_changed(config: ModConfig) -> void:
	# Check if the config of your mod has changed!
	if config.mod_id == "torcado-nametag":
		Global.apply_config.emit(config)


func _ready() -> void:
	# Get the current config
	var config = ModLoaderConfig.get_current_config("torcado-nametag")
	# Connect to current_config_changed signal
	ModLoader.current_config_changed.connect(_on_current_config_changed)
	
	ModLoaderLog.info("Ready!", AUTHORNAME_MODNAME_LOG_NAME)

func _disable():
	Global.disable.emit()

