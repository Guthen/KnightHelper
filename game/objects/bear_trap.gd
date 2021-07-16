extends Node2D


func _ready():
	pass 


func _on_Area2D_body_entered( body ):
	if body and body.layers == 2:
		$AnimatedSprite.set_frame( 1 )
		body.is_freezed = true
		body.position = position + Vector2( 0, -4 )
