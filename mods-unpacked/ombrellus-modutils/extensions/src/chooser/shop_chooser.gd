extends Control

@onready var OMutils = get_node("/root/ModLoader/ombrellus-modutils")
var icon:TextureRect = null

func up_gui(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Audio.play(preload("res://src/sounds/click2.ogg"), 0.8, 1.2, "ui")
			if OMutils.shopNum > 0:
				OMutils.shopNum -= 1
				changeShop(OMutils.shopNum,OMutils.shopNum+1)

func changeShop(id:int,last_id:int):
	if icon == null:
		icon = Global.shop.get_node("CanvasLayer/Items/VBoxContainer/HBoxContainer/MarginContainer/TextureRect")
	if OMutils.shopNum != 0:
		var currency = OMutils.customCurrencies[OMutils.shops[OMutils.shopNum]]
		%Label.text = currency.name
		icon.texture = currency.icon
		Global.shop.coin_count.label_settings.font_color = currency.color
	else:
		icon.texture = preload("res://src/ui/coin_count/coin.svg")
		%Label.text = "Coins"
		Global.shop.coin_count.label_settings.font_color = Color(0.659, 0.2, 1)
	Global.shop.shopSaves[last_id] = Global.shop.curItems.duplicate()
	for i in 3:
		replaceWithSave(i,id)

func replaceWithSave(index:int,shop:int):
	if Global.shop.shopSaves.has(shop):
		var slot = Global.shop.item_slots[index]
		var item = slot.get_child(0)
		item.queue_free()
		var newItem = Global.shop.ShopItem.instantiate()
		var choice = Global.shop.shopSaves[shop][index]
		newItem.entry = choice
		newItem.index = index
		newItem.bought = false
		slot.add_child(newItem)
		slot.move_child(newItem, 0)
		Global.shop.curItems[index] = choice
		Global.shop.updateItems()
	else:
		Global.shop.replaceItem(index)
		Global.shop.updateItems()

func down_gui(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Audio.play(preload("res://src/sounds/click2.ogg"), 0.8, 1.2, "ui")
			if OMutils.shopNum < OMutils.shops.size()-1:
				OMutils.shopNum += 1
				changeShop(OMutils.shopNum,OMutils.shopNum-1)
