extends CharacterBody2D

@export var movement_speed = 20.0

@onready var player = get_tree().get_first_node_in_group("player")

# "_" przy delcie oznacza, że nie jest ona wykorzystywana
func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	
	velocity = direction * movement_speed
	
	move_and_slide()
