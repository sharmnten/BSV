extends Area2D

var state = ""
var watered = false
@onready var plant = $Plant # Assuming $Plant is a node like AnimatedSprite2D that displays plant growth
var days_planted = -1 # Start at -1 so first call to next_day makes it 0
var ready_for_harvest=false
@onready var player_node: Node = get_node("../../player")
var crop_type: String = "" # Track what crop is planted
var crop_data: CropData = null

#define rng

# Called when the node enters the scene tree for the fdirst time.
func _ready() -> void:
	state  = "untilled"
	# Connect the signal from the Player
	if is_instance_valid(player_node) and player_node.has_signal("next_day"):
		player_node.next_day.connect(_on_player_next_day)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# This is the method that will run when the 'next_day' signal is detected
func _on_player_next_day():
	if((watered&&state=="planted")&&ready_for_harvest==false):
		days_planted=days_planted+1
		if crop_data:
			days_planted = days_planted % crop_data.growth_days
		else:
			days_planted = days_planted % 3
		plant.play("day_"+str(days_planted))
		watered=false
		$AnimatedSprite2D.play("tilled")
	elif(watered):
		watered = false
		$AnimatedSprite2D.play("tilled")
	if crop_data and days_planted == crop_data.growth_days - 1:
		ready_for_harvest=true
	elif not crop_data and days_planted == 2:
		ready_for_harvest=true
		
		
# Setters and getters (already provided)
func get_harvest()->bool:
	return ready_for_harvest
func set_state(target_state)->void:
	state = target_state
func get_state()->String:
	return state
func set_watered(param)->void:
	watered = param
func get_watered()->bool:
	return watered
func harvested()->String:
	var harvested_crop = crop_type
	plant.play("default")
	ready_for_harvest=false
	days_planted=-1
	state = "tilled"
	crop_type = ""
	crop_data = null
	return harvested_crop

func plant_crop(type: String)->void:
	crop_type = type
	if CropManager.instance:
		crop_data = CropManager.instance.get_crop(type)
	state = "planted"
	plant.play("planted")
