extends KinematicBody2D

export var health: float = 100
export var max_health: float = 100
export var speed: int = 75
export var is_looking_left: bool = false
export var is_freezed: bool = false

onready var game = get_node( "/root/Game" )

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
	
	if not game.is_running or is_freezed or dir == Vector2.ZERO:
		$AnimatedSprite.play( "idle" )
		return
	
	#  flip sprite
	if not ( dir.x == 0 ):
		$AnimatedSprite.flip_h = dir.x < 0
		is_looking_left = $AnimatedSprite.flip_h
	
	#  move
	move_and_slide( dir.normalized() * speed )
	$AnimatedSprite.play( "walk" )

func take_damage( damage: int ):
	health -= damage
	last_damage_time = 0
	if health < 0:
		get_tree().reload_current_scene()

func get_movement_direction() -> Vector2:
	return Vector2.ZERO