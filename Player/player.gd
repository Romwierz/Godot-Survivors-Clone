extends CharacterBody2D

@export var movement_speed = 40.0
@export var hp = 80
var last_movement = Vector2.UP

var experience = 0 
var experience_level = 1 
var collected_experience = 0 

# Attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")

# AttackNodes
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")

# Ice Spear
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 0

# Tornado
var tornado_ammo = 0
var tornado_baseammo = 1
var tornado_attackspeed = 1.5
var tornado_level = 0
var attack_count = 0

# Javelin
var javelin_ammo = 3
var javelin_level = 1

# Enemy Related
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%WalkTimer")

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelup")

func _ready():
	attack()
	set_expbar(experience, calculate_experiencecap())

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
		last_movement = direction
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame = 1
			walkTimer.start()
	
	move_and_slide() # wbudowana funkcja sprawiająca, że postać się porusza

func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	
	if javelin_level > 0:
		spawn_javelin()

func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= damage
	#print("Player HP:", hp)

func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo
	iceSpearAttackTimer.start()

func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

# dodaj przeciwnika do zmiennej enemy_close jeśli jest w obszarze, ale nie ma go w zmiennej
func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

# usuń przeciwnika ze zmiennej enemy_close jeśli jest poza obszarem i jest w zmiennej
func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)

func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo
	tornadoAttackTimer.start()
	attack_count += 1

func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()

func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = javelin_ammo - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1

func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)

func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required: #level up
		# po level upie może zostać niewykorzystane xp
		collected_experience -= exp_required-experience
		experience_level += 1
		lblLevel.text = str("Level: ", experience_level)
		experience = 0
		# przeliczenie do kolejnego level upu
		# nie wystarczy że jest to w pierwszej linii funkcji?
		exp_required = calculate_experiencecap()
		levelup()
		calculate_experience(0)
	else:
		experience += collected_experience
		collected_experience = 0
	
	set_expbar(experience, exp_required)

# oblicza, ile potrzeba exp do level upu
func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level*5
	elif experience_level < 40:
		exp_cap = 95 * (experience_level-19)*8
	else:
		exp_cap = 255 + (experience_level-39)*12
		
	return exp_cap
		
func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

func levelup():
	sndLevelUp.play()
	lblLevel.text = str("Level: ",experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(220,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		#option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true

func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		#"armor1","armor2","armor3","armor4":
			#armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 20.0
		#"tome1","tome2","tome3","tome4":
			#spell_size += 0.10
		#"scroll1","scroll2","scroll3","scroll4":
			#spell_cooldown += 0.05
		#"ring1","ring2":
			#additional_attacks += 1
		#"food":
			#hp += 20
			#hp = clamp(hp,0,maxhp)
	#adjust_gui_collection(upgrade)
	attack()
	var option_children = upgradeOptions.get_children()
	# usunięcie wszystkich children
	for i in option_children:
		i.queue_free()
	#upgrade_options.clear()
	#collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800, 50)
	get_tree().paused = false
	calculate_experience(0)
