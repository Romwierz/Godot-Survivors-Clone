extends CharacterBody2D

@export var movement_speed = 20.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
#@onready var walkTimer = %WalkTimer
@onready var animation = $AnimationPlayer

func _ready():
	animation.play("walk")

# "_" przy delcie oznacza, że nie jest ona wykorzystywana
func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	
	velocity = direction * movement_speed
	
	if velocity.x > 0:
		$Sprite2D.set_flip_h(true)
	elif velocity.x < 0:
		sprite.set_flip_h(false)
	
	#if velocity != Vector2.ZERO:
		#if walkTimer.is_stopped():
			#if sprite.frame >= sprite.hframes - 1:
				#sprite.frame = 0
			#else:
				#sprite.frame = 1
			#walkTimer.start()
	
	move_and_slide()
