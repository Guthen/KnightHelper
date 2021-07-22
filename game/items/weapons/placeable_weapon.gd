extends "res://game/items/scn_placeable_item.gd"

export var weapon_data: Resource

func _ready():
	pass


func _on_PickupArea_body_entered( body: PhysicsBody2D ):
	if not game.is_running or not ( body == game.player ):
		return
	
	if weapon_data:
		body.call_deferred( "set_weapon", weapon_data )
		queue_free()
