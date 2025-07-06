extends Control

@onready var crop_list = $VBoxContainer/CropList
@onready var close_button = $VBoxContainer/CloseButton
var player_inventory: Inventory

func _ready():
	visible = false
	close_button.pressed.connect(_on_close_pressed)

func show_shop(inventory: Inventory):
	player_inventory = inventory
	visible = true
	_populate_crop_list()
	get_tree().paused = true

func _populate_crop_list():
	# Clear existing items
	for child in crop_list.get_children():
		child.queue_free()
	
	# Add available crops
	var available_crops = CropManager.instance.get_available_crops()
	for crop in available_crops:
		var item_container = HBoxContainer.new()
		
		var label = Label.new()
		label.text = crop.name + " Seeds - " + str(crop.seed_price) + " coins"
		label.custom_minimum_size.x = 300
		
		var buy_button = Button.new()
		buy_button.text = "Buy"
		buy_button.pressed.connect(_on_buy_pressed.bind(crop))
		
		item_container.add_child(label)
		item_container.add_child(buy_button)
		crop_list.add_child(item_container)

func _on_buy_pressed(crop: CropData):
	if player_inventory.spend_money(crop.seed_price):
		player_inventory.add_item(crop.name.to_lower() + "_seeds", 1)
		# Update the shop display
		_populate_crop_list()
	else:
		print("Not enough money!")

func _on_close_pressed():
	visible = false
	get_tree().paused = false

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close_pressed()