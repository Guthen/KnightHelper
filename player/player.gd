extends KinematicBody2D
var speed = 100


func _ready():
	pass 

func _physics_process( delta ):
	var dir = Vector2()
	
	if Input.is_action_pressed( "up" ):
		dir.y -= 1
	if Input.is_action_pressed( "down" ):
		dir.y += 1
	if Input.is_action_pressed( "left" ):
		dir.x -= 1 
	if Input.is_action_pressed( "right" ):
		dir.x += 1
	
	if dir == Vector2.ZERO:
		return
	
	#  flip sprite
	if not ( dir.x == 0 ):
		$AnimatedSprite.flip_h = dir.x < 0
	
	#  move
	move_and_slide( dir.normalized() * speed )