extends Node2D

onready var weapon_origin = $Pivot/Pos
onready var weapon = weapon_origin.get_node( "Weapon" )
onready var anim_player = $AnimationPlayer

var weapon_data: Resource
var attack_count: int = 0

var is_attacking: bool setget set_attacking
var has_recovered: bool = true 

func _ready():
	set_attacking( false )
	set_weapon_node( weapon )

func set_weapon_node( weapon: Area2D ):
	self.weapon = weapon
	weapon.character_owner = get_parent()

func set_attacking( value: bool ):
	is_attacking = value
	weapon.toggle_hitbox( value )

func set_pivot_rotation( ang: float ):
	$Pivot.rotation = ang - PI
	z_index = 1 if ang < 0 else 0

func attack( ang: float ):
	if not weapon_data or not has_recovered:
		return
	
	weapon.prepare()
	has_recovered = false
	set_attacking( true )
	
	set_pivot_rotation( ang )
	if weapon_data.type == "stab":
		anim_player.stop()
		anim_player.play( "stab" )
	else:
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
	weapon.free()
	weapon = data.weapon.instance()
	weapon_origin.add_child( weapon )
	set_weapon_node( weapon )
	
	#weapon.set_image( data.image )
	weapon.weapon_data = data
	weapon.visible = true
	set_attacking( false )
	
	weapon_data = data
