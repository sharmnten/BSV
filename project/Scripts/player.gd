extends CharacterBody2D


const SPEED = 300.0
var current_tool = ""
var current_crop_type = "corn" # Default crop type
@onready var inventory: Inventory = Inventory.new()
var max_energy = 100
var current_energy = 100
var energy_costs = {
	"hoe": 10,
	"can": 5,
	"seeds": 3
}

signal next_day

@onready var cornAmount = get_node("%hotbar/Hotbar4")
@onready var seedAmount = get_node("%hotbar/Hotbar3")
@onready var coin = get_node("./Camera2D/Coin")
@onready var crop_label = get_node("./Camera2D/CropType")
@onready var energy_bar = get_node("./Camera2D/EnergyBar")
@onready var energy_label = get_node("./Camera2D/EnergyLabel")
@onready var notification_manager = NotificationManager.new()

@warning_ignore("unused_parameter")
func _ready():
	add_child(inventory)
	add_child(notification_manager)
	inventory.inventory_changed.connect(_on_inventory_changed)
	add_to_group("player")
	_update_ui()
func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	var y_direction= Input.get_axis("up","down")
	if direction:
		velocity.x = direction * SPEED
		if(velocity.x <0):
			$AnimatedSprite2D.play("left")
		elif(velocity.x>0):
			$AnimatedSprite2D.play("right")
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if y_direction:
		velocity.y = y_direction * SPEED
		if(velocity.y <0):
			$AnimatedSprite2D.play("up")
		elif(velocity.y>0):
			$AnimatedSprite2D.play("down")
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)
	if(velocity.x==0&&velocity.y==0):
			$AnimatedSprite2D.play("default")
	move_and_slide()
func _input(event) -> void:
	if(event.is_action_pressed("space")):
		var collisions= $InteractionZone.get_overlapping_areas()
		for i in range(collisions.size()):
			if(collisions[i].is_in_group("ground")):
				if((current_tool=="hoe")&&(collisions[i].get_state()=="untilled")):
					if use_energy("hoe"):
						collisions[i].set_state("tilled")
						var animate = collisions[i].get_node("AnimatedSprite2D")
						animate.play("tilled")
						var tilled = collisions[i].get_node("Tilled")
						tilled.emitting=true
						print("tilled")
					break
				elif(current_tool=="can"&&(collisions[i].get_state()=="tilled"||collisions[i].get_state()=="planted")):
					if use_energy("can"):
						collisions[i].set_watered(true)
						var animate = collisions[i].get_node("AnimatedSprite2D")
						animate.play("watered")#TODO:CHANGE THIS ANIMATION
						$CanEffect.emitting=true
						print("watered")
					break
				elif(current_tool=="seeds"&&(collisions[i].get_state()=="tilled")):
					var seed_name = current_crop_type + "_seeds"
					if(inventory.get_item_count(seed_name) > 0):
						if use_energy("seeds"):
							if CropManager.instance and CropManager.instance.can_grow_in_current_season(current_crop_type):
								inventory.remove_item(seed_name, 1)
								collisions[i].plant_crop(current_crop_type)
								@warning_ignore("unused_variable")
								var animate = collisions[i].get_node("AnimatedSprite2D")
							else:
								notification_manager.show_notification("Can't grow in " + CropManager.instance.get_current_season() + "!", 2.0, Color.RED)
					print("planted " + current_crop_type)
					break
				elif(current_tool == "hoe"&&collisions[i].ready_for_harvest==true):
					if use_energy("hoe"):
						var harvested_crop = collisions[i].harvested()
						var particle = collisions[i].get_node("Plant/CPUParticles2D")
						particle.emitting=true
						if harvested_crop:
							inventory.add_item(harvested_crop, 1)
			elif(collisions[i].is_in_group("sell_area")):
				var total_value = 0
				for item_name in inventory.items:
					if not item_name.ends_with("_seeds"):
						var crop = CropManager.instance.get_crop(item_name)
						if crop:
							var count = inventory.items[item_name]
							total_value += count * crop.sell_price
							inventory.remove_item(item_name, count)
				if total_value > 0:
					var coin_explosion = collisions[i].get_node("CPUParticles2D")
					coin_explosion.emitting = true
					inventory.add_money(total_value)
					notification_manager.show_notification("+" + str(total_value) + " coins!", 2.0, Color.GOLD)
			elif(collisions[i].is_in_group("store")):
				# Buy current selected crop type
				var crop = CropManager.instance.get_crop(current_crop_type)
				if crop and inventory.spend_money(crop.seed_price):
					inventory.add_item(current_crop_type + "_seeds", 1)
					notification_manager.show_notification("Bought " + crop.name + " seeds!", 2.0, Color.GREEN)
				else:
					notification_manager.show_notification("Not enough money!", 2.0, Color.RED)
				
	elif(event.is_action_pressed("f")):
		next_day.emit()
		restore_energy(50) # Restore some energy on new day
	if(event.is_action_pressed("1")):
		current_tool="hoe"
	if(event.is_action_pressed("2")):
		current_tool = "can"
	if(event.is_action_pressed("3")):
		current_tool = "seeds"
	if(event.is_action_pressed("q")):
		cycle_crop_type()

func _on_inventory_changed():
	_update_ui()

func _update_ui():
	seedAmount.set_text(inventory.get_total_seeds())
	cornAmount.set_text(inventory.get_total_crops())
	coin.text = "Coins: " + str(inventory.money)
	if crop_label:
		crop_label.text = "Crop: " + current_crop_type.capitalize()
	if energy_bar and energy_label:
		energy_bar.value = current_energy
		energy_label.text = "Energy: " + str(int(current_energy)) + "/" + str(max_energy)

func cycle_crop_type():
	# Cycle through available crops for current season
	var available = CropManager.instance.get_available_crops()
	if available.is_empty():
		return
	
	var current_index = -1
	for i in range(available.size()):
		if available[i].name.to_lower() == current_crop_type:
			current_index = i
			break
	
	current_index = (current_index + 1) % available.size()
	current_crop_type = available[current_index].name.to_lower()
	print("Selected crop: " + current_crop_type)

func use_energy(tool: String) -> bool:
	var cost = energy_costs.get(tool, 0)
	if current_energy >= cost:
		current_energy -= cost
		_update_ui()
		return true
	else:
		notification_manager.show_notification("Not enough energy!", 2.0, Color.RED)
		return false

func restore_energy(amount: int):
	current_energy = min(current_energy + amount, max_energy)
	_update_ui()
