extends "res://game/items/scn_placeable_item.gd"

export var damage: int = 40
var is_activated = false

func _ready():
	is_activated = false 


func _on_Area2D_body_entered( body ):
	if not game.is_running or is_activated:
		return
	
	is_activated = true
	$AnimatedSprite.set_frame( 1 )
	
	body.is_freezed = true
	#body.position = position #+ Vector2( 0, -6 )
	body.take_damage( damage )
	#body.take_damage( 40, position.direction_to( body.position ) * 50 )
	
	yield( get_tree().create_timer( 1 ), "timeout" )
	
	#  check if it's not deleted
	if weakref( body ).get_ref():
		body.is_freezed = false
