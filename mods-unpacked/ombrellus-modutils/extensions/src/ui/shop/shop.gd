extends "res://src/ui/shop/shop.gd"

@onready var OMutils = get_node("/root/ModLoader/ombrellus-modutils")

var shopSaves:Dictionary={
	
}

func replaceItem(index:int, start := false):
	super.replaceItem(index,start)
	if OMutils.shopNum != 0:
		var item = item_slots[index].get_child(0)
		var currentShop = OMutils.customShopsData[OMutils.shops[OMutils.shopNum]]
		item.queue_free()
		var newItem = ShopItem.instantiate()
		var newChoices = currentShop.values()
		for i in range(newChoices.size()-1,-1,-1):
			if newChoices[i].weight <= 0.0:
				newChoices.remove_at(i)
		var choice = Utils.weightedRandom(newChoices)
		var i := 0
		newItem.entry = choice
		newItem.index = index
		newItem.bought = false
		item_slots[index].add_child(newItem)
		item_slots[index].move_child(newItem, 0)
		curItems[index] = choice

func buyItemWithCurrency(index:int):
	focusedItem = Focus.focusedControl
	var item = item_slots[index].get_child(0)
	var price = item.entry.price.call()
	var type = item.entry.ModUtils_currency
	if jackpot:
		price = ceil(price/2.0)
	if OMutils.customCurrencies[type].check.call() >= price:
		OMutils.customCurrencies[type].use.call(price)
		Stats.stats.totalShopPurchases += 1
		Stats.metaStats.totalShopPurchases += 1
		Stats.stats.totalShopItems += 1
		Stats.metaStats.totalShopItems += 1
		item.entry.buy.call()
		item.buy()
		if item.entry.has("count"):
			item.entry.count += 1
		if item.entry.get("action", false):
			queueAction(item.entry)
		Audio.play(preload("res://src/sounds/buy.ogg"), 0.8, 1.2)
		boughtIndex = index
		updateItems()
		
		if OMutils.shopNum != 0:
			var currency = OMutils.customCurrencies[OMutils.shops[OMutils.shopNum]]
			coin_count.text = str(currency.check.call())
		
		Events.itemBought.emit(item)
		return true
	return false

func _ready():
	super._ready()
	if OMutils.shops != [1]:
		var choose = preload("res://mods-unpacked/ombrellus-modutils/extensions/src/chooser/shop_chooser.tscn").instantiate()
		choose.position = Vector2(670,470)
		$CanvasLayer/Items.add_child(choose)


func _process(delta):
	super._process(delta)
	if OMutils.shopNum != 0: 
		coin_count.text = str(OMutils.customCurrencies[OMutils.shops[OMutils.shopNum]].check.call())
	
