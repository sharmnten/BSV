extends HBoxContainer

signal hoe_selected
signal can_selected
signal seeds_selected

func _ready():
	$Hotbar3.set_text(0)
	$Hotbar4.set_text(0)

func _input(event)->void:
	if(event.is_action("1")):
		$Hotbar1.selected()
		$Hotbar2.deselect()
		$Hotbar3.deselect()
		$Hotbar4.deselect()
		emit_signal("hoe_selected")
		print("hoe selected")
	elif(event.is_action("2")):
		$Hotbar1.deselect()
		$Hotbar2.selected()
		$Hotbar3.deselect()
		$Hotbar4.deselect()
		emit_signal("can_selected")
		print("can selected")
	elif(event.is_action("3")):
		$Hotbar1.deselect()
		$Hotbar2.deselect()
		$Hotbar3.selected()
		$Hotbar4.deselect()
		emit_signal("seeds_selected")
		print("seeds selected")
	elif(event.is_action("4")):
		$Hotbar1.deselect()
		$Hotbar2.deselect()
		$Hotbar3.deselect()
		$Hotbar4.selected()
		
