extends "res://character/character.gd"

func _ready():
	target = game.player

func on_stop_target():
	attack_at( target.global_position )
