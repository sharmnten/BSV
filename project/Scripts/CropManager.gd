extends Node
class_name CropManager

# Singleton for managing all crop types
static var instance: CropManager

var crops: Dictionary = {}
var current_season: String = "spring"
var season_order = ["spring", "summer", "fall", "winter"]
var days_per_season = 28

signal season_changed(new_season: String)

func _ready():
	instance = self
	load_all_crops()

func load_all_crops():
	# Load corn
	var corn = CropData.new()
	corn.name = "Corn"
	corn.seed_price = 25
	corn.sell_price = 50
	corn.growth_days = 3
	corn.description = "A versatile crop that grows in summer and fall"
	corn.season_requirements = ["summer", "fall"]
	crops["corn"] = corn
	
	# Load tomato
	var tomato = CropData.new()
	tomato.name = "Tomato"
	tomato.seed_price = 15
	tomato.sell_price = 35
	tomato.growth_days = 2
	tomato.description = "Fast-growing crop perfect for beginners"
	tomato.season_requirements = ["spring", "summer"]
	crops["tomato"] = tomato
	
	# Load pumpkin
	var pumpkin = CropData.new()
	pumpkin.name = "Pumpkin"
	pumpkin.seed_price = 40
	pumpkin.sell_price = 120
	pumpkin.growth_days = 5
	pumpkin.description = "Takes time but yields high profit"
	pumpkin.season_requirements = ["fall"]
	crops["pumpkin"] = pumpkin
	
	# Load wheat
	var wheat = CropData.new()
	wheat.name = "Wheat"
	wheat.seed_price = 10
	wheat.sell_price = 25
	wheat.growth_days = 2
	wheat.description = "Basic crop that grows in most seasons"
	wheat.season_requirements = ["spring", "summer", "fall"]
	crops["wheat"] = wheat
	
	# Load strawberry
	var strawberry = CropData.new()
	strawberry.name = "Strawberry"
	strawberry.seed_price = 60
	strawberry.sell_price = 100
	strawberry.growth_days = 4
	strawberry.description = "Sweet berries that keep producing"
	strawberry.season_requirements = ["spring"]
	crops["strawberry"] = strawberry

func get_crop(crop_name: String) -> CropData:
	return crops.get(crop_name, null)

func can_grow_in_current_season(crop_name: String) -> bool:
	var crop = get_crop(crop_name)
	if not crop:
		return false
	if crop.season_requirements.is_empty():
		return true
	return current_season in crop.season_requirements

func get_available_crops() -> Array:
	var available = []
	for crop_name in crops:
		if can_grow_in_current_season(crop_name):
			available.append(crops[crop_name])
	return available

func update_season(current_day: int):
	var season_index = (current_day / days_per_season) % season_order.size()
	var new_season = season_order[season_index]
	if new_season != current_season:
		current_season = new_season
		season_changed.emit(current_season)
		print("Season changed to: " + current_season)

func get_current_season() -> String:
	return current_season
