extends "res://src/ui/upgrade_shop/upgradeShopItem.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func buy():
	super.buy()
	utils.upgradeBought.emit(entry)
