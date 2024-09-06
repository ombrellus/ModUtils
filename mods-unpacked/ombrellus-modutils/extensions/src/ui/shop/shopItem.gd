extends "res://src/ui/shop/shopItem.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func updateGroup():
	if not Players.inMultiplayer:
		for c in Players.getUniqueChars():
			print("hallo")
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

