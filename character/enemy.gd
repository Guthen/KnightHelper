extends "res://character/character.gd"

var path_compute_timer = 0
var path_compute_time = .25

func _ready():
	target = game.player
	path_compute_timer = path_compute_time

func _process( dt ):
	path_compute_timer -= dt
	if path_compute_timer <= 0:
		find_path( target.position )
		path_compute_timer = path_compute_time

func on_stop_target():
	if is_freezed:
		return
	
	attack_at( target.global_position )

func on_death():
	queue_free()
