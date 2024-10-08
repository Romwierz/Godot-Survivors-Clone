extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitbox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = %DisableTimer

signal hurt(damage, angle, knockback)

var hit_once_array = []

# area(attack) to hit_box przeciwnika
func _on_area_entered(area):
	if area.is_in_group("attack"):
		if area.get("damage") != null:
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set", "disabled", true) # wyłącza collison (CollisionShape2D)
					disableTimer.start()
				1: #HitOnce
					# sprawdzenie czy pocisk znajduje się w tablicy
					if hit_once_array.has(area):
						return
					else:
						# dodanie pocisku do tablicy
						hit_once_array.append(area)
						if area.has_signal("remove_from_array"):
							# połączenie sygnału z funkcją usuwająca pocisk z tablicy
							if not area.is_connected("remove_from_array", Callable(self, "remove_from_list")):
								area.connect("remove_from_array", Callable(self, "remove_from_list"))
				2: #DisableHitbox
					if area.has_method("tempdisable"):
						area.tempdisable()
			var damage = area.damage
			var angle = Vector2.ZERO
			var knockback = 1
			if area.get("angle") != null:
				angle = area.angle
			if area.get("knockback_amount") != null:
				knockback = area.knockback_amount
			emit_signal("hurt", damage, angle, knockback)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

# usuwa z tablicy pocisk, który już spełnił swoje zadanie i został usunięty
func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)

func _on_disable_timer_timeout():
	collision.call_deferred("set", "disabled", false) # włącza collison (CollisionShape2D)
