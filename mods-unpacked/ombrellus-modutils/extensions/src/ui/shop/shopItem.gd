extends "res://src/ui/shop/shopItem.gd"

@onready var utils = get_node("/root/ModLoader/ombrellus-modutils")

func updateGroup():
	if not Players.inMultiplayer:
		for c in Players.getUniqueChars():
			print("hallo")
			if Players.charData[c].has("mod") :
				print("there is mod")
				var newIcon = utils._findItemIcon(entry.internalName,Players.charData[c].internalName,Players.charData[c].mod)
				if newIcon!= null:
					groupIcons = [newIcon]
				var newName = utils._findItemName(entry.internalName,Players.charData[c].internalName,Players.charData[c].mod)
				if newName!= "OkIHopeNoOneUsesThisLineAsAnActualName":
					groupNames = [newName]
	else:
		for c in Players.getUniqueChars():
			if Players.charData[c].has("mod") :
				#var chars:Array[int] = Players.getUniqueChars()
				#var charPos:int = chars.find(c)
				var newIcon = utils._findItemIcon(entry.internalName,Players.charData[c].internalName,Players.charData[c].mod)
				if newIcon!= null:
					Utils.addUnique(groupIcons,newIcon)
					
				var newName = utils._findItemName(entry.internalName,Players.charData[c].internalName,Players.charData[c].mod)
				if newName!= "OkIHopeNoOneUsesThisLineAsAnActualName":
					Utils.addUnique(groupNames,newName)
	super.updateGroup()

