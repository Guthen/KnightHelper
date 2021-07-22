extends Area2D

var character_owner: Node2D
var weapon_data: Resource
var damaged_bodies: Dictionary

func _ready():
	pass

func prepare():
	damaged_bodies = {}

func toggle_hitbox( value: bool ):
	$CollisionShape2D.set_deferred( "disabled", not value )
	set_physics_process( value )

func _physics_process( dt ):
	for body in get_overlapping_bodies():
		if not ( body is KinematicBody2D ) or body == character_owner or damaged_bodies.get( body ):
			continue
		
		body.take_damage( weapon_data.damage, ( body.global_position - global_position ).normalized() * weapon_data.knockback_force )
		damaged_bodies[body] = true
