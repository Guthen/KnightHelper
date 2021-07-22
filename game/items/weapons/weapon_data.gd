extends Resource

class_name WeaponData

export var damage: int = 15  #  how much damage per hit on characters
export (String, "swing", "stab") var type = "swing"  #  animation type
export var image: Texture
export var weapon: PackedScene
export var attack_time: float = .7  #  characters can be hit during that time 
export var recover_time: float = .2  #  time to be able to attack again 
export var knockback_force: int = 50  #  force multiplicator on knockback

func _ready():
	pass
