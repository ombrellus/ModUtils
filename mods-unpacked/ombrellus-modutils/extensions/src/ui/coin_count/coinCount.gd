extends "res://src/ui/coin_count/coinCount.gd"

@onready var OMutils = get_node("/root/ModLoader/ombrellus-modutils")

func update():
	super.update()
	if type >= 2:
		coin_count.label_settings.font_color = OMutils.customCurrencies[type].color
		coin_icon.texture = OMutils.customCurrencies[type].icon
