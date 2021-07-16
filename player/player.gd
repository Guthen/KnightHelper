extends Node2D


func _ready():
	pass 

func _process( delta ):
	var right = Input.is_action_just_pressed( "ui_right" )
	var left = Input.is_action_just_pressed( "ui_left" )
	var up = Input.is_action_just_pressed( "ui_up" )
	var down = Input.is_action_just_pressed( "ui_down" )
	
	if right:
		position.x += 16
	elif left:
		position.x -= 16
	elif up:
		position.y -= 16
	elif down:
		position.y += 16
