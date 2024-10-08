extends CharacterBody2D

@export var movement_speed = 20.0
@export var hp = 80
@export var knockback_recovery = 3.5
@export var experience = 1
@export var enemy_damage = 1
var knockback = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
#@onready var walkTimer = %WalkTimer
@onready var animation = $AnimationPlayer
@onready var snd_hit = $snd_hit
@onready var hitBox = $HitBox

var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://Objects/experience_gem.tscn")

signal remove_from_array(object)

func _ready():
	animation.play("walk")
	hitBox.damage = enemy_damage

# "_" przy delcie oznacza, że nie jest ona wykorzystywana
func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	
	var direction = global_position.direction_to(player.global_position)
	
	velocity = direction * movement_speed
	velocity += knockback
	
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

func death():
	# call_deferred sprawiają, że funkcje wykonują się po queue_free()
	emit_signal("remove_from_array", self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	queue_free() #usuwa przeciwnika z gry

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	hp -= damage
	knockback = angle * knockback_amount
	#print("Enemy HP:", hp)
	if hp <= 0:
		death()
	else:
		snd_hit.play()
