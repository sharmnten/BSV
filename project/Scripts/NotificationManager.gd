extends Node
class_name NotificationManager

var active_notifications = []

func show_notification(text: String, duration: float = 2.0, color: Color = Color.WHITE):
	var notification = Label.new()
	notification.text = text
	notification.modulate = color
	notification.z_index = 100
	
	# Style the notification
	notification.add_theme_font_size_override("font_size", 30)
	notification.add_theme_color_override("font_color", color)
	notification.add_theme_color_override("font_shadow_color", Color.BLACK)
	notification.add_theme_constant_override("shadow_offset_x", 2)
	notification.add_theme_constant_override("shadow_offset_y", 2)
	
	# Position it above the player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_child(notification)
		notification.position = Vector2(-100, -100)
		
		# Animate the notification
		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		
		# Float up and fade out
		tween.parallel().tween_property(notification, "position:y", -150, duration)
		tween.parallel().tween_property(notification, "modulate:a", 0, duration)
		
		tween.tween_callback(notification.queue_free)
		
		active_notifications.append(notification)
