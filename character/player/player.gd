extends "res://character/character.gd"

func _ready():
	pass

func get_movement_direction() -> Vector2:
	var dir = Vector2()
	
	if Input.is_action_pressed( "up" ):
		dir.y -= 1
	if Input.is_action_pressed( "down" ):
		dir.y += 1
	if Input.is_action_pressed( "left" ):
		dir.x -= 1 
	if Input.is_action_pressed( "right" ):
		dir.x += 1
	
	return dir


func _on_Player_on_take_damage( damage: int, velocity: Vector2 ):
	if health <= 0:
		game.camera.position = position
		game.camera.desired_zoom *= .75
		game.anim_player.play( "fade_out" )
