extends "res://src/ui/shop/shop.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")


func _ready():
	abilityChoices.merge(utils.customCharAbility)
	super._ready()
	shopItemChoices.merge(utils.customUpgrades)
