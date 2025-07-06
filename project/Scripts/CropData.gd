extends Resource
class_name CropData

@export var name: String = ""
@export var seed_price: int = 25
@export var sell_price: int = 50
@export var growth_days: int = 3
@export var texture_path: String = ""
@export var seed_texture_path: String = ""
@export var description: String = ""
@export var season_requirements: Array = []  # Empty means grows in all seasons

# Growth stage textures (day_0, day_1, etc.)
@export var growth_textures: Array = []