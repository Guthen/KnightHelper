extends "res://game/items/scn_placeable_item.gd"

export var weapon: PackedScene

func _ready():
	pass


func _on_PickupArea_body_entered( body ):
	if weapon:
		body.hold_weapon( weapon.instance() )
		queue_free()
