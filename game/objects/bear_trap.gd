extends Node2D

export var damage: int = 40
var is_activated = false

func _ready():
	pass 


func _on_Area2D_body_entered( body ):
	if is_activated:
		return
	
	if body and body.layers == 2:
		is_activated = true
		$AnimatedSprite.set_frame( 1 )
		
		body.is_freezed = true
		body.position = position #+ Vector2( 0, -6 )
		body.take_damage( damage )
		#body.take_damage( 40, position.direction_to( body.position ) * 50 )
		
		yield( get_tree().create_timer( 1 ), "timeout" )
		body.is_freezed = false
