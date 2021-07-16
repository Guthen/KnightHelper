extends Node2D

var is_activated = false

func _ready():
	pass 


func _on_Area2D_body_entered( body ):
	if is_activated:
		return
	
	if body and body.layers == 2:
		is_activated = true
		$AnimatedSprite.set_frame( 1 )
		
		body.position = position + Vector2( 0, -10 )
		body.is_freezed = true
		body.take_damage( 40 )
		
		yield( get_tree().create_timer( 1 ), "timeout" )
		body.is_freezed = false
