extends KinematicBody2D
var speed = 40

func _ready():
	pass 

func _physics_process( delta ):
	var dir = Vector2()
	
	if Input.is_action_pressed( "up" ):
		$AnimatedSprite.play("Walk")
		dir.y -= 1
	if Input.is_action_pressed( "down" ):
		$AnimatedSprite.play("Walk")
		dir.y += 1
	if Input.is_action_pressed( "left" ):
		$AnimatedSprite.play("Walk")
		dir.x -= 1 
	if Input.is_action_pressed( "right" ):
		$AnimatedSprite.play("Walk")
		dir.x += 1
	else: 
		$AnimatedSprite.stop()
	
	if dir == Vector2.ZERO:
		return
	
	#  flip sprite
	if not ( dir.x == 0 ):
		$AnimatedSprite.flip_h = dir.x < 0
	
	#  move
	move_and_slide( dir.normalized() * speed )
