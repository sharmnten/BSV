extends ItemList

signal hoe_selected
signal can_selected
signal seeds_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _input(event)->void:
	if(event.is_action("1")):
		select(0)
		emit_signal("hoe_selected")
		print("hoe selected")
	elif(event.is_action("2")):
		select(1)
		emit_signal("can_selected")
		print("can selected")
	elif(event.is_action("3")):
		select(2)
		emit_signal("seeds_selected")
		print("seeds selected")
		
