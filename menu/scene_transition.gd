extends Node

signal on_animation_finished

func _ready():
	pass

func play( anim_name ):
	$AnimationPlayer.play( anim_name )

func prepare():
	$Control/CircleMask.texture_scale = 0

func reset():
	$Control/CircleMask.texture_scale = 50

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal( "on_animation_finished", anim_name )
