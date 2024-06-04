extends Resource

class_name Spawn_info

# kiedy przeciwnicy mają się zrespić
@export var time_start: int
@export var time_end: int
# określa typ przeciwnika
@export var enemy: Resource
# liczba
@export var enemy_num: int
# czas pomiędzy respami
@export var enemy_spawn_delay: int

# zlicza czas pomiędzy respami
var spawn_delay_counter = 0 
