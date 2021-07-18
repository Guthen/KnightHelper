extends Node2D

onready var weapon = $Pivot/Pos/WeaponEntity
onready var anim_player = $AnimationPlayer

var weapon_data: Resource
var attack_count: int = 0

var is_attacking: bool setget set_attacking
var has_recovered: bool = true 

func _ready():
	set_attacking( false )

func set_attacking( value: bool ):
	is_attacking = value
	weapon.toggle_hitbox( value )

func attack( ang: float ):
	if not weapon_data or not has_recovered:
		return
	
	has_recovered = false
	set_attacking( true )
	
	$Pivot.rotation = ang - PI
	anim_player.play( weapon_data.type + "_" + str( fmod( attack_count, 2 ) + 1 ) )
	
	$Pivot/Pos.rotation = PI if fmod( attack_count, 2 ) == 1 else 0
	#weapon.flip_image( )
	
	
	attack_count += 1
	
	#  attack time
	yield( get_tree().create_timer( weapon_data.attack_time ), "timeout" )
	set_attacking( false )
	
	#  recover time
	yield( get_tree().create_timer( weapon_data.recover_time ), "timeout" )
	has_recovered = true

func set_weapon( data: Resource ):
	weapon.set_image( data.image )
	weapon.weapon_data = data
	weapon.visible = true
	set_attacking( false )
	
	weapon_data = data
