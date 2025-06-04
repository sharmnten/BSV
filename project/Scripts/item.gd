extends Node2D

@onready var animation = $AnimatedSprite2D
var value = 0 
func selected():
	animation.play("selected")
func deselect():
	animation.play("default") 
func set_text(param:int)->void:
	$Amount.text = str(param)
	value = param
func get_text()->int:
	return value
