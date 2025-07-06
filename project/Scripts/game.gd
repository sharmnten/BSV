extends Node2D

var day = 0
@onready var day_text = get_node("player/Camera2D/Day")
@onready var season_text = get_node("player/Camera2D/Season")
@onready var crop_manager = CropManager.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(crop_manager)
	crop_manager.season_changed.connect(_on_season_changed)
	_update_season_display()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _input(event) -> void:
	if(event.is_action_pressed("f")):
		day = day+1
		day_text.text = "Day "+str(day)
		crop_manager.update_season(day)
	if event.is_action_pressed("save_game"):
		save_game()
	if event.is_action_pressed("load_game"):
		load_game()

func _on_season_changed(new_season: String):
	_update_season_display()
	# Kill all crops that can't grow in this season
	var tile_map = get_node("TileMapLayer")
	for child in tile_map.get_children():
		if child.has_method("get_state") and child.get_state() == "planted":
			if child.crop_type != "" and not crop_manager.can_grow_in_current_season(child.crop_type):
				child.harvested()
				print(child.crop_type + " died due to season change")

func _update_season_display():
	if season_text:
		season_text.text = "Season: " + crop_manager.get_current_season().capitalize()
		# Update season color
		match crop_manager.get_current_season():
			"spring":
				season_text.modulate = Color(0.5, 1, 0.5)
			"summer":
				season_text.modulate = Color(1, 1, 0.5)
			"fall":
				season_text.modulate = Color(1, 0.7, 0.4)
			"winter":
				season_text.modulate = Color(0.8, 0.9, 1)

func save_game():
	var player = get_node("player")
	var tile_map = get_node("TileMapLayer")
	
	# Collect all ground tiles data
	var ground_tiles = []
	for child in tile_map.get_children():
		if child.has_method("get_state"):
			var tile_data = {
				"position": child.position,
				"state": child.get_state(),
				"watered": child.get_watered(),
				"crop_type": child.crop_type,
				"days_planted": child.days_planted,
				"ready_for_harvest": child.ready_for_harvest
			}
			ground_tiles.append(tile_data)
	
	var save_data = {
		"day": day,
		"player_position": player.position,
		"inventory": player.inventory.items,
		"money": player.inventory.money,
		"current_crop_type": player.current_crop_type,
		"current_energy": player.current_energy,
		"current_season": crop_manager.current_season,
		"ground_tiles": ground_tiles
	}
	
	if SaveGame.save_game(save_data):
		print("Game saved!")
		show_save_indicator("Game Saved!")

func load_game():
	var save_data = SaveGame.load_game()
	if save_data.is_empty():
		return
	
	var player = get_node("player")
	var tile_map = get_node("TileMapLayer")
	
	# Restore basic data
	day = save_data.get("day", 0)
	day_text.text = "Day " + str(day)
	player.position = save_data.get("player_position", Vector2.ZERO)
	player.inventory.items = save_data.get("inventory", {})
	player.inventory.money = save_data.get("money", 0)
	player.current_crop_type = save_data.get("current_crop_type", "corn")
	player.current_energy = save_data.get("current_energy", 100)
	crop_manager.current_season = save_data.get("current_season", "spring")
	
	# Restore ground tiles
	var ground_tiles = save_data.get("ground_tiles", [])
	for tile_data in ground_tiles:
		for child in tile_map.get_children():
			if child.position == tile_data["position"]:
				child.set_state(tile_data["state"])
				child.set_watered(tile_data["watered"])
				child.crop_type = tile_data["crop_type"]
				child.days_planted = tile_data["days_planted"]
				child.ready_for_harvest = tile_data["ready_for_harvest"]
				
				# Update visuals
				if tile_data["state"] == "tilled":
					child.get_node("AnimatedSprite2D").play("tilled")
				elif tile_data["state"] == "planted":
					if tile_data["days_planted"] >= 0:
						child.get_node("Plant").play("day_" + str(tile_data["days_planted"]))
				if tile_data["watered"]:
					child.get_node("AnimatedSprite2D").play("watered")
				break
	
	# Update UI
	player._update_ui()
	_update_season_display()
	crop_manager.update_season(day)
	print("Game loaded!")
	show_save_indicator("Game Loaded!")

func show_save_indicator(text: String):
	var indicator = get_node("player/Camera2D/SaveIndicator")
	if indicator:
		indicator.text = text
		indicator.visible = true
		await get_tree().create_timer(2.0).timeout
		indicator.visible = false
		
	
