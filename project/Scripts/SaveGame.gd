extends Node
class_name SaveGame

const SAVE_PATH = "user://savegame.dat"

static func save_game(game_data: Dictionary):
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		save_file.store_var(game_data)
		save_file.close()
		print("Game saved successfully")
		return true
	return false

static func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return {}
	
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file:
		var game_data = save_file.get_var()
		save_file.close()
		print("Game loaded successfully")
		return game_data
	return {}

static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save file deleted")