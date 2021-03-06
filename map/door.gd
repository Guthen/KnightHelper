extends Node2D

onready var game = get_node( "/root/Game" )

func _ready():
	pass

func _on_Area2D_body_entered( body ):
	if not game.is_running:
		return
	
	if not ( body == game.player ):
		return
	
	game.fade_out( self, self, "on_fade_out" )
	$AudioStreamPlayer.play()

func on_fade_out():
	yield( get_tree().create_timer( .5 ), "timeout" )
	if not game.change_level( game.level_id + 1 ):
		get_tree().change_scene( "res://menu/WinMenu.tscn" )
