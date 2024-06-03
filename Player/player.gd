extends CharacterBody2D

var movement_speed = 40.0

func _physics_process(delta):
	movement(delta)

func movement(delta):
	var x_mov = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_mov = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var mov = Vector2(x_mov, y_mov)
	
	velocity = mov.normalized() * movement_speed
	
	move_and_slide() # built-in function that cause character to move
