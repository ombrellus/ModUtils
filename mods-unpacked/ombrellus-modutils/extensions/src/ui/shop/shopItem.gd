extends "res://src/ui/shop/shopItem.gd"

@onready var OMutils = get_node("/root/ModLoader/ombrellus-modutils")

func updateGroup():
	if not Players.inMultiplayer:
		for c in Players.getUniqueChars():
			if Players.charData[c].has("mod") :
				for i in Players.charData[c].shopOverrides:
					var override = Players.charData[c].shopOverrides[i]
					if entry.internalName == i:
						if override.has("name"):
							groupNames = [override.name]
						if override.has("icon"):
							groupIcons = [override.icon]
	else:
		for c in Players.getUniqueChars():
			if Players.charData[c].has("mod") :
				for i in Players.charData[c].shopOverrides:
					var override = Players.charData[c].shopOverrides[i]
					if entry.internalName == i:
						if override.has("name"):
							Utils.addUnique(groupIcons,override.name)
						if override.has("icon"):
							Utils.addUnique(groupNames,override.icon)
	super.updateGroup()

func activate():
	if not bought and canBuy and not choose:
		if entry.has("ModUtils_currency"):
			Global.shop.buyItemWithCurrency(index)
			return
	super.activate()

func update():
	super.update()
	if not bought:
		if not entry.is_empty():
			if entry.has("ModUtils_currency"):
				var price = entry.price.call()
				if Global.shop.jackpot: price = ceil(price/2.0)
				canAfford = OMutils.customCurrencies[entry.ModUtils_currency].check.call() >= price
				padding.visible = false
				
				coin_count.type = entry.ModUtils_currency
				coin_count.update()
				
			if canBuy and canAfford and panel != null:
				panel.modulate = Utils.color(1.0)
				cycle_container.modulate = Utils.color(1.0)
				level_container.modulate = Utils.color(1.0)
				action_container.modulate = Utils.color(1.0)
			elif panel != null:
				panel.modulate = Utils.color(0.5)
				cycle_container.modulate = Utils.color(0.5)
				level_container.modulate = Utils.color(0.5)
				action_container.modulate = Utils.color(0.5)
				#panel.modulate = Color(0.46, 0.46, 0.54)
				#cycle_container.modulate = Color(0.46, 0.46, 0.54)
				#level_container.modulate = Color(0.46, 0.46, 0.54)
				#action_container.modulate = Color(0.46, 0.46, 0.54)
			
			if canAfford and panel != null:
				coin_container.modulate = Color.WHITE
			elif panel != null:
				coin_container.modulate = Color(0.9, 0.1, 0.1)


