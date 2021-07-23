extends Control

onready var anim_player = $AnimationPlayer

func _ready():
	anim_player.play( "setup" )
	
	yield( get_tree().create_timer( 1 ), "timeout" )
	anim_player.play( "fade_in" )
	
	Utility.current_level_id = 0

func _on_AnimationPlayer_animation_finished( anim_name ):
	if anim_name == "fade_in":
		yield( get_tree().create_timer( 1 ), "timeout" )
		anim_player.play( "fade_out" )
	elif anim_name == "fade_out":
		get_tree().change_scene( "res://menu/MainMenu.tscn" )
