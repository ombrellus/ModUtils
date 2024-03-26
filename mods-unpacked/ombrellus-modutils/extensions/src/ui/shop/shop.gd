extends "res://src/ui/shop/shop.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func _ready():
	super._ready()
	shopItemChoices.merge(utils.customUpgrades)
