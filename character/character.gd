extends KinematicBody2D

class_name Character

export var health: float = 100
export var max_health: float = 100
export var speed: int = 75
export var is_looking_left: bool = false
export var is_freezed: bool = false
export var velocity: Vector2 = Vector2.ZERO
export var weapon_data: Resource

onready var game = get_node( "/root/Game" )
onready var start_dust_particles_x = $DustParticles.position.x
onready var start_dust_particles_dir_y = $DustParticles.direction.y

var holding_weapon: Node2D
var last_damage_time: float = 0
var target: Node2D
var default_stop_target_dist_sqr: int = 64 ^ 2
var stop_target_dist_sqr: int = default_stop_target_dist_sqr

signal on_death
signal on_take_damage

func _ready():
	if is_looking_left:
		$AnimatedSprite.flip_h = true
	
	if weapon_data:
		$WeaponController.set_weapon( weapon_data )

func _process( dt ):
	last_damage_time += dt
	
	#  target
	if target and weakref( target ).get_ref():
		$WeaponController.set_pivot_rotation( get_angle_to( target.global_position ) )
	
	#  hud
	var ratio = health / max_health
	$HUD/HealthRect.rect_scale.x = max( lerp( $HUD/HealthRect.rect_scale.x, ratio, dt * 4 ), 0 )
	if last_damage_time > .5:
		$HUD/HealthRectDamage.rect_scale.x = max( lerp( $HUD/HealthRectDamage.rect_scale.x, ratio, dt * 5 ), 0 )

func _physics_process( dt ):	
	if not ( velocity == Vector2.ZERO ):
		move_and_slide( velocity )
		velocity = velocity.move_toward( Vector2.ZERO, dt * 100 )
	
	if health <= 0:
		return
	
	var dir = get_movement_direction()
	if not game.is_running or is_freezed or dir == Vector2.ZERO:
		$AnimatedSprite.play( "idle" )
		$DustParticles.emitting = false
		return
	
	#  flip sprite
	if not ( dir.x == 0 ):
		$AnimatedSprite.flip_h = dir.x < 0
		is_looking_left = $AnimatedSprite.flip_h
		
		#$WeaponController.position.x = abs( $WeaponController.position.x ) * dir.x
		#$WeaponController.scale.x = dir.x
		
		$DustParticles.position.x = abs( start_dust_particles_x ) * -dir.x + ( 1 if dir.x >= 0 else 0 )
		$DustParticles.direction.x = abs( $DustParticles.direction.x ) * -dir.x

	$DustParticles.direction.y = start_dust_particles_dir_y * dir.y
	
	#  move
	move_and_slide( dir.normalized() * speed )
	$AnimatedSprite.play( "walk" )
	$DustParticles.emitting = true

func take_damage( damage: int, velocity: Vector2 = Vector2.ZERO ):
	health -= damage
	last_damage_time = 0
	emit_signal( "on_take_damage", damage, velocity )
	
	self.velocity += velocity
	
	$AnimatedSprite.material.set_shader_param( "IS_ACTIVE", true )
	yield( get_tree().create_timer( .25 ), "timeout" )
	$AnimatedSprite.material.set_shader_param( "IS_ACTIVE", false )
	
	if health <= 0:
		$AnimatedSprite.playing = false
		emit_signal( "on_death" )

func attack( ang: float ):
	$WeaponController.attack( ang )

func get_angle_to( pos: Vector2 ) -> float:
	return global_position.angle_to_point( pos )

func attack_at( pos: Vector2 ):
	attack( get_angle_to( pos ) )

func set_weapon( weapon: Resource ):
	$WeaponController.set_weapon( weapon )

func on_stop_target():
	pass

func get_movement_direction() -> Vector2:
	if target and weakref( target ).get_ref():
		if target.position.distance_squared_to( position ) <= stop_target_dist_sqr:
			on_stop_target()
			return Vector2.ZERO
		
		return position.direction_to( target.position )
	
	return Vector2.ZERO
