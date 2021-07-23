extends "res://game/items/scn_placeable_item.gd"


func _ready():
	game.connect( "on_game_running", self, "on_game_running" )

func _process( dt ):
	if game.is_running and not $CPUParticles2D.emitting:
		queue_free()


func can_place_on( body: PhysicsBody2D ):
	return body.is_in_group( "breakables" )

func on_game_running():
	for body in $Area2D.get_overlapping_bodies():
		if can_place_on( body ):
			body.queue_free()
			break
	
	Pathfinder.init_navigation_map()
	
	$ExplosionSoundPlayer.stream = Utility.explosion_sounds[randi() % len( Utility.explosion_sounds )]
	$ExplosionSoundPlayer.play()
	
	$Sprite.visible = false
	$CPUParticles2D.emitting = true

func _on_Area2D_body_entered( body ):
	if not game.is_running or not ( body == game.player ):
		return
	
	body.get_node( "PickupSoundPlayer" ).play()
	queue_free()
