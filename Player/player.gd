extends CharacterBody2D

var movement_speed = 40.0
@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%WalkTimer")

func _physics_process(_delta):
	movement()

func movement():
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	velocity = direction * movement_speed # nie ma potrzeby normalizowania
	
	if velocity.x > 0:
		$Sprite2D.set_flip_h(true)
	elif velocity.x < 0:
		sprite.set_flip_h(false)
	
	if velocity != Vector2.ZERO:
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame = 1
			walkTimer.start()
	
	print(get_velocity().x)
	
	move_and_slide() # wbudowana funkcja sprawiająca, że postać się porusza
