extends "res://src/ui/shop/shopItem.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func buy():
	super.buy()
	match entry.priceType:
		0:
			utils.itemBought.emit(entry)
		1:
			utils.upgradeBought.emit(entry)
