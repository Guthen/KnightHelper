extends Control

onready var anim_player = $AnimationPlayer
onready var scene_transition = $SceneTransition

var method: String = ""
var time: float = 0

func _ready():
	scene_transition.prepare()
	yield( get_tree().create_timer( .5 ), "timeout" )
	scene_transition.play( "fade_in" )
	anim_player.play( "fade_in" )

func _process( dt ):
	time += dt
	$LogoSprite.rotation_degrees = sin( time * 2 ) * 5

func play_sound():
	$AudioStreamPlayer.stream = Utility.select_sounds[randi() % len( Utility.select_sounds )]
	$AudioStreamPlayer.play()

func _on_PlayButton_pressed():
	method = "play"
	scene_transition.play( "fade_out" )
	play_sound()

func _on_QuitButton_pressed():
	method = "quit"
	scene_transition.play( "fade_out" )
	play_sound()

func _on_SceneTransition_on_animation_finished( anim_name: String ):
	if anim_name == "fade_out":
		if method == "quit":
			get_tree().quit()
		elif method == "play":
			get_tree().change_scene( "res://game/Game.tscn" )
