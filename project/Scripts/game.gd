extends Node2D

var day = 0
@onready var day_text = get_node("player/Camera2D/Day")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _input(event) -> void:
	if(event.is_action_pressed("f")):
		day = day+1
		day_text.text = "Day "+str(day)
		
	
