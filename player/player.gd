extends KinematicBody2D

export var health: float = 100
export var max_health: float = 100
export var speed: int = 40
var is_freezed: bool = false

onready var game = get_node( "/root/Game" )

func _ready():
	pass

var last_damage_time = 0
func _process( dt ):
	last_damage_time += dt
	
	var ratio = health / max_health
	$HUD/HealthRect.rect_scale.x = lerp( $HUD/HealthRect.rect_scale.x, ratio, dt * 4 )
	if last_damage_time > .5:
		$HUD/HealthRectDamage.rect_scale.x = lerp( $HUD/HealthRectDamage.rect_scale.x, ratio, dt * 5 )

func _physics_process( dt ):
	var dir = Vector2()
	
	if Input.is_action_pressed( "up" ):
		dir.y -= 1
	if Input.is_action_pressed( "down" ):
		dir.y += 1
	if Input.is_action_pressed( "left" ):
		dir.x -= 1 
	if Input.is_action_pressed( "right" ):
		dir.x += 1
	
	if not game.is_running or is_freezed or dir == Vector2.ZERO:
		$AnimatedSprite.play( "idle" )
		return
	
	#  flip sprite
	if not ( dir.x == 0 ):
		$AnimatedSprite.flip_h = dir.x < 0
	
	#  move
	move_and_slide( dir.normalized() * speed )
	$AnimatedSprite.play( "walk" )

func take_damage( damage: int ):
	health -= damage
	last_damage_time = 0
	if health < 0:
		get_tree().reload_current_scene()
