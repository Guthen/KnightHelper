extends KinematicBody2D

export var health: float = 100
export var max_health: float = 100
export var speed: int = 75
export var is_looking_left: bool = false
export var is_freezed: bool = false
export var velocity: Vector2 = Vector2.ZERO

onready var game = get_node( "/root/Game" )
onready var start_dust_particles_x = $DustParticles.position.x
onready var start_dust_particles_dir_y = $DustParticles.direction.y

signal on_death

func _ready():
	if is_looking_left:
		$AnimatedSprite.flip_h = true

var last_damage_time = 0
func _process( dt ):
	last_damage_time += dt
	
	var ratio = health / max_health
	$HUD/HealthRect.rect_scale.x = lerp( $HUD/HealthRect.rect_scale.x, ratio, dt * 4 )
	if last_damage_time > .5:
		$HUD/HealthRectDamage.rect_scale.x = lerp( $HUD/HealthRectDamage.rect_scale.x, ratio, dt * 5 )

func _physics_process( dt ):
	var dir = get_movement_direction()
	
	if not ( velocity == Vector2.ZERO ):
		move_and_slide( velocity )
		velocity = velocity.move_toward( Vector2.ZERO, dt * 100 )
	
	if not game.is_running or is_freezed or dir == Vector2.ZERO:
		$AnimatedSprite.play( "idle" )
		$DustParticles.emitting = false
		return
	
	#  flip sprite
	if not ( dir.x == 0 ):
		$AnimatedSprite.flip_h = dir.x < 0
		is_looking_left = $AnimatedSprite.flip_h
		
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
	
	self.velocity += velocity
	
	$AnimatedSprite.material.set_shader_param( "IS_ACTIVE", true )
	yield( get_tree().create_timer( .25 ), "timeout" )
	$AnimatedSprite.material.set_shader_param( "IS_ACTIVE", false )
	
	if health < 0:
		emit_signal( "on_death", damage, velocity )

func get_movement_direction() -> Vector2:
	return Vector2.ZERO
