extends Area2D

var level = 1
var hp = 9999
var speed = 100.0
var damage = 5
var attack_size = 1.0
var knockback_amount = 100

var last_movement = Vector2.ZERO
var angle = Vector2.ZERO
var angle_less = Vector2.ZERO
var angle_more = Vector2.ZERO

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	
	attack_size *= 1 + player.spell_size
	match level:
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			knockback_amount = 125
	
	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	
	if last_movement.x > 0:
		last_movement.x = 1
	elif last_movement.x < 0:
		last_movement.x = -1
	
	if last_movement.y > 0:
		last_movement.y = 1
	elif last_movement.y < 0:
		last_movement.y = -1
	
	match last_movement:
		Vector2.UP, Vector2.DOWN:
			move_to_less = global_position + Vector2(randf_range(-1, -0.25), last_movement.y) * 500
			move_to_more = global_position + Vector2(randf_range(0.25, 1), last_movement.y) * 500
		Vector2.LEFT, Vector2.RIGHT:
			move_to_less = global_position + Vector2(last_movement.x, randf_range(-1, -0.25)) * 500
			move_to_more = global_position + Vector2(last_movement.x, randf_range(0.25, 1)) * 500
		Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1):
			move_to_less = global_position + Vector2(last_movement.x, last_movement.y * randf_range(0, 0.75)) * 500
			move_to_more = global_position + Vector2(last_movement.x * randf_range(0, 0.75), last_movement.y) * 500
	
	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)
	
	# płynnie zwiększa rozmiar i prędkość tornada
	var initial_tween = create_tween().set_parallel(true)
	var tween_1_duration = 3
	initial_tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, tween_1_duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var final_speed = speed
	speed /= 5.0
	initial_tween.tween_property(self, "speed", final_speed, tween_1_duration * 2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	initial_tween.play()
	
	# płynnie zmienia angle
	var tween = create_tween()
	var tween_2_duration = 2
	var set_angle = randi_range(0, 1)
	if set_angle == 1:
		angle = angle_less
		tween.tween_property(self, "angle", angle_more, tween_2_duration)
		tween.tween_property(self, "angle", angle_less, tween_2_duration)
	else:
		angle = angle_more
		tween.tween_property(self, "angle", angle_less, tween_2_duration)
		tween.tween_property(self, "angle", angle_more, tween_2_duration)
	tween.set_loops(3)
	tween.play()
	
func _physics_process(delta):
	position += angle * speed * delta
	print(angle)

func enemy_hit(_charge):
	pass

func _on_timer_timeout():
	emit_signal("remove_from_array")
	queue_free()
