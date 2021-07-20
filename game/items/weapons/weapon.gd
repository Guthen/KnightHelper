extends Node2D

var weapon_data: Resource

func _ready():
	pass

func set_image( image: Texture ):
	$Weapon/Sprite.texture = image

func toggle_hitbox( value: bool ):
	$Weapon/HitArea/CollisionShape2D.set_deferred( "disabled", not value )

func flip_image( value: bool ):
	$Weapon/Sprite.flip_v = value

func _on_HitArea_body_entered( body ):
	body.take_damage( weapon_data.damage, ( body.global_position - $Weapon/HitArea.global_position ).normalized() * weapon_data.knockback_force )
