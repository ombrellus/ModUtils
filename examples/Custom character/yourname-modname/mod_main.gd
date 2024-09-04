extends Node

const AUTHORNAME_MODNAME_DIR := "yourname-modname" # Name of the directory that this file is in
const AUTHORNAME_MODNAME_LOG_NAME := "yourname-modname:Main" # Full ID of the mod (AuthorName-ModName)

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

@onready var modUtils = get_node("/root/ModLoader/ombrellus-modutils")

var coolAbilityCount:int = 0

var myCharacter:Dictionary ={
		internalName = "cool_character",
		displayName = "Cool",
		ability_name = "Cool ability",
		ability_icon = preload("res://src/player/bubbleBig.png"),
		abilityCooldown = func(delta):
			Global.abilityCooldown -= 1.0/(25.0 - TorCurve.smoothCorner(max(1, coolAbilityCount), 19.0, 1.8, 2.8)) * delta,
		wallShrinkSpeed = 1,
		wallResistance = 1,
		priceScale = 1.0,
		shopOverrides = {},
		# leave blank
		skins = [""],
		baseWealth = 0,
		spritesExtension = ".svg",
		unlocked = true,
	}
var charAbility:Dictionary={
		internalName = "cool",
		name = (func()->Array:
			return ["Cool ability"]
			),
		icon = (func()->Array:
			return [load("res://src/player/bubbleBig.png")]
			),
		priceType = 1,
		value = (func():
			return coolAbilityCount
			),
		price = (func(): 
			return (coolAbilityCount+1)
			),
		buy = (func():
			coolAbilityCount += 1
			Global.abilityCount += 1
			Global.usableAbilityCount += 1
			),
		description = (func():
			var list = [
				"1",
				"2",
				"3"
			]
			if coolAbilityCount < list.size():
				return list[coolAbilityCount]
			return ""
			),
		weight = 1.0,
		_weight = 1.0
	}

# ! your _ready func.
func _init() -> void:
	ModLoaderLog.info("Init", AUTHORNAME_MODNAME_LOG_NAME)
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(AUTHORNAME_MODNAME_DIR)
	install_script_extensions()


func install_script_extensions() -> void:
	# ! any script extensions should go in this directory, and should follow the same directory structure as vanilla
	extensions_dir_path = mod_dir_path.path_join("extensions")


func _ready() -> void:
	ModLoaderLog.info("Ready", AUTHORNAME_MODNAME_LOG_NAME)
	modUtils.addCustomCharacter(AUTHORNAME_MODNAME_DIR,myCharacter,charAbility)
	Events.runStarted.connect(func():
		coolAbilityCount = 0)


