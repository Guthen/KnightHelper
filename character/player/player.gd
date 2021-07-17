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

func _on_NPC_on_death():
	get_tree().reload_current_scene()
