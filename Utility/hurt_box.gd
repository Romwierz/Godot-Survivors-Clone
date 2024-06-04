extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitbox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = %DisableTimer

signal hurt(damage)

# area(attack) to hit_box przeciwnika
func _on_area_entered(area):
	if area.is_in_group("attack"):
		if area.get("damage") != null:
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set", "disabled", true) # wyłącza collison (CollisionShape2D)
					disableTimer.start()
				1: #HitOnce
					pass
				2: #DisableHitbox
					if area.has_method("tempdisable"):
						area.tempdisable()
			var damage = area.damage
			emit_signal("hurt", damage)

func _on_disable_timer_timeout():
	collision.call_deferred("set", "disabled", false) # włącza collison (CollisionShape2D)
