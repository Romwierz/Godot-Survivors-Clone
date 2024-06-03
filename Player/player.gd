extends CharacterBody2D

var movement_speed = 40.0

func _physics_process(delta):
	movement(delta)

func movement(delta):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	velocity = direction * movement_speed # nie ma potrzeby normalizowania
	
	move_and_slide() # wbudowana funkcja sprawiająca, że postać się porusza
