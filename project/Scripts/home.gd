extends Control


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/credits.tscn")


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game Objects/game.tscn")
