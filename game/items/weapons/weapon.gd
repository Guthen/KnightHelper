extends Node2D

var weapon_data: Resource

func _ready():
	pass

func set_image( image: Texture ):
	$Sprite.texture = image

func toggle_hitbox( value: bool ):
	$HitArea/CollisionShape2D.set_deferred( "disabled", not value )

func flip_image( value: bool ):
	$Sprite.flip_v = value

func _on_HitArea_body_entered( body ):
	print( "contact with: ", body )
	body.take_damage( weapon_data.damage, ( body.global_position - $HitArea.global_position ).normalized() * weapon_data.knockback_force )
