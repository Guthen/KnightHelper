extends Node2D

onready var game = get_node( "/root/Game" )
onready var level = game.level_id

var is_activated = false
func _ready():
	is_activated = false 


func _on_Area2D_body_entered( body ):
	if not game.is_running or is_activated:
		return
	is_activated = true
	game.change_level(level + 1)
