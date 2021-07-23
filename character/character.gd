extends KinematicBody2D

class_name Character

export var health: float = 100
export var max_health: float = 100
export var speed: int = 75
export var is_looking_left: bool = false
export var is_freezed: bool = false
export var velocity: Vector2 = Vector2.ZERO
export var direction_velocity_draining: float = 5
export var weapon_data: Resource
export var team_id: int = -1

onready var game = get_node( "/root/Game" )
onready var start_dust_particles_x = $DustParticles.position.x
onready var start_dust_particles_dir_y = $DustParticles.direction.y

var is_idle: bool = true
var direction_velocity: Vector2 = Vector2.ZERO
var holding_weapon: Node2D
var last_damage_time: float = 0
var target: Node2D
var default_stop_target_dist_sqr: int = pow( 12, 2 )
var stop_target_dist_sqr: int = default_stop_target_dist_sqr
var path: PoolVector2Array

func _ready():
	if is_looking_left:
		$AnimatedSprite.flip_h = true
	
	if weapon_data:
		$WeaponController.set_weapon( weapon_data )

func _process( dt ):
	last_damage_time += dt
	
	if health > 0:
		#  target
		if target and weakref( target ).get_ref() and $WeaponController.weapon_data:
			$WeaponController.set_pivot_rotation( get_angle_to( target.global_position ) )
	
	#  hud
	var ratio = health / max_health
	$HUD/HealthRect.rect_scale.x = max( lerp( $HUD/HealthRect.rect_scale.x, ratio, dt * 4 ), 0 )
	if last_damage_time > .5:
		$HUD/HealthRectDamage.rect_scale.x = max( lerp( $HUD/HealthRectDamage.rect_scale.x, ratio, dt * 5 ), 0 )

func _physics_process( dt ):	
	if not ( velocity == Vector2.ZERO ):
		move_and_slide( velocity * 2.5 )
		velocity = velocity.move_toward( Vector2.ZERO, dt * 100 )
	
	var dir = get_movement_direction()
	if health <= 0 or not game.is_running or is_freezed or dir == Vector2.ZERO:
		$AnimatedSprite.play( "idle" )
		$DustParticles.emitting = false
		is_idle = true
		return
	
	direction_velocity = direction_velocity.move_toward( dir, dt * direction_velocity_draining )
	dir = direction_velocity
	
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
	if $AnimatedSprite.frames.has_animation( "walk" ):
		$AnimatedSprite.play( "walk" )
	$DustParticles.emitting = true
	is_idle = false

func find_path( pos: Vector2 ):
	path = Pathfinder.find_path( position, pos )
	
	if Pathfinder.debug and self == game.player:
		var path_preview = game.get_node( "PathPreview" ) as Line2D
		path_preview.clear_points()
		for pos in path:
			path_preview.add_point( pos )
	
	return path.size() > 0

func is_team_mate( body: Character ):
	return team_id > 0 and body.team_id > 0 and team_id == body.team_id

func take_damage( damage: int, velocity: Vector2 = Vector2.ZERO ):
	health -= damage
	last_damage_time = 0
	on_take_damage( damage, velocity )
	
	self.velocity += velocity
	if health <= 0:
		$WeaponController.weapon.toggle_hitbox( false )
	
	$HurtSoundPlayer.stream = Utility.hurt_sounds[randi() % len( Utility.hurt_sounds )]
	$HurtSoundPlayer.play()
	
	$AnimatedSprite.material.set_shader_param( "IS_ACTIVE", true )
	yield( get_tree().create_timer( .25 ), "timeout" )
	$AnimatedSprite.material.set_shader_param( "IS_ACTIVE", false )
	
	if health <= 0:
		$AnimatedSprite.playing = false
		$WeaponController.visible = false
		on_death()

func attack( ang: float ):
	$WeaponController.attack( ang )

func get_angle_to( pos: Vector2 ) -> float:
	return global_position.angle_to_point( pos )

func attack_at( pos: Vector2 ):
	attack( get_angle_to( pos ) )

func set_weapon( weapon: Resource ):
	$WeaponController.set_weapon( weapon )
	weapon_data = weapon

func on_stop_target():
	pass

func on_death():
	pass

func on_take_damage( damage: int, velocity: Vector2 ):
	pass

func get_movement_direction() -> Vector2:
	if target and weakref( target ).get_ref():
		if target.position.distance_squared_to( position ) <= stop_target_dist_sqr:
			on_stop_target()
			return Vector2.ZERO
		elif path and path.size() > 0:
			var near_dist = INF
			var near_pos = path[0]
			
			var i = 0
			for pos in path:
				var dist = position.distance_squared_to( pos )
				if position.distance_squared_to( pos ) <= 32:
					for j in range( 0, i + 1 ):
						path.remove( 0 )
					continue
				
				if dist < near_dist:
					near_dist = dist
					near_pos = pos
				
				i += 1
			
			return position.direction_to( near_pos )
		
		return position.direction_to( target.position )
	
	return Vector2.ZERO
