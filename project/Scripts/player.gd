extends CharacterBody2D


const SPEED = 300.0
var current_tool = ""
var money = 0


var seeds = 7

signal next_day

@onready var cornAmount = get_node("%hotbar/Hotbar4")
@onready var seedAmount = get_node("%hotbar/Hotbar3")
@onready var coin = get_node("./Camera2D/Coin")

@warning_ignore("unused_parameter")
func _ready():
	seedAmount.set_text(seeds)
func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	var y_direction= Input.get_axis("up","down")
	if direction:
		velocity.x = direction * SPEED
		if(velocity.x <0):
			$AnimatedSprite2D.play("left")
		elif(velocity.x>0):
			$AnimatedSprite2D.play("right")
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if y_direction:
		velocity.y = y_direction * SPEED
		if(velocity.y <0):
			$AnimatedSprite2D.play("up")
		elif(velocity.y>0):
			$AnimatedSprite2D.play("down")
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)
	if(velocity.x==0&&velocity.y==0):
			$AnimatedSprite2D.play("default")
	move_and_slide()
func _input(event) -> void:
	if(event.is_action_pressed("space")):
		var collisions= $InteractionZone.get_overlapping_areas()
		for i in range(collisions.size()):
			if(collisions[i].is_in_group("ground")):
				if((current_tool=="hoe")&&(collisions[i].get_state()=="untilled")):
					collisions[i].set_state("tilled")
					var animate = collisions[i].get_node("AnimatedSprite2D")
					animate.play("tilled")
					var tilled = collisions[i].get_node("Tilled")
					tilled.emitting=true
					print("tilled")
					break
				elif(current_tool=="can"&&(collisions[i].get_state()=="tilled"||collisions[i].get_state()=="planted")):
					collisions[i].set_watered(true)
					var animate = collisions[i].get_node("AnimatedSprite2D")
					animate.play("watered")#TODO:CHANGE THIS ANIMATION
					$CanEffect.emitting=true
					print("watered")
					break
				elif(current_tool=="seeds"&&(collisions[i].get_state()=="tilled")):
					if(seeds>0):
						seeds = seeds-1
						seedAmount.set_text(seeds)
						collisions[i].set_state("planted")
						var plant = collisions[i].get_node("Plant")
						plant.play("planted")
						@warning_ignore("unused_variable")
						var animate = collisions[i].get_node("AnimatedSprite2D")
					#animate.play("tilled")#TODO: CHANGE ANIMATION
					print("planted")
					break
				elif(current_tool == "hoe"&&collisions[i].ready_for_harvest==true):
					collisions[i].harvested()
					var particle = collisions[i].get_node("Plant/CPUParticles2D")
					particle.emitting=true
					cornAmount.set_text(cornAmount.get_text()+1)
			elif(collisions[i].is_in_group("sell_area")):
				if(cornAmount.get_text()>0):
					var coin_explosion = collisions[i].get_node("CPUParticles2D")
					coin_explosion.emitting = true
					money = money+cornAmount.get_text()*50
					coin.text = "Coins: "+str(money)
					cornAmount.set_text(0)
			elif(collisions[i].is_in_group("store")):
				if(money>=25):
					money = money-25
					coin.text = "Coin: "+str(money)
					seeds = seeds +1
					seedAmount.set_text(seeds)
				
	elif(event.is_action_pressed("f")):
		next_day.emit()
	if(event.is_action_pressed("1")):
		current_tool="hoe"
	if(event.is_action_pressed("2")):
		current_tool = "can"
	if(event.is_action_pressed("3")):
		current_tool = "seeds"
