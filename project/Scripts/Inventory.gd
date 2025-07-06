extends Node
class_name Inventory

signal inventory_changed

var items: Dictionary = {}
var money: int = 0

func _ready():
	# Start with some corn seeds
	add_item("corn_seeds", 7)

func add_item(item_name: String, quantity: int):
	if items.has(item_name):
		items[item_name] += quantity
	else:
		items[item_name] = quantity
	inventory_changed.emit()

func remove_item(item_name: String, quantity: int) -> bool:
	if not items.has(item_name) or items[item_name] < quantity:
		return false
	items[item_name] -= quantity
	if items[item_name] == 0:
		items.erase(item_name)
	inventory_changed.emit()
	return true

func get_item_count(item_name: String) -> int:
	return items.get(item_name, 0)

func add_money(amount: int):
	money += amount
	inventory_changed.emit()

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		inventory_changed.emit()
		return true
	return false

func get_total_seeds() -> int:
	var total = 0
	for item_name in items:
		if item_name.ends_with("_seeds"):
			total += items[item_name]
	return total

func get_total_crops() -> int:
	var total = 0
	for item_name in items:
		if not item_name.ends_with("_seeds") and CropManager.instance and CropManager.instance.get_crop(item_name):
			total += items[item_name]
	return total