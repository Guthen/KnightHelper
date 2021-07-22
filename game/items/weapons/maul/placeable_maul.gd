extends "res://game/items/scn_placeable_item.gd"

export var weapon_data: Resource

func _ready():
	pass


func _on_PickupArea_body_entered( body ):
	if weapon_data:
		body.set_weapon( weapon_data )
		queue_free()
