extends "res://game/items/scn_placeable_item.gd"


func _ready():
	pass

func _process( dt ):
	if game.is_running and not $CPUParticles2D.emitting:
		queue_free()
		

func _physics_process( dt ):
	if not game.is_running:
		return
		
	for body in $Area2D.get_overlapping_bodies():
		if can_place_on( body ):
			body.queue_free()
			break
	
	Pathfinder.init_navigation_map()
	
	$Sprite.visible = false
	$CPUParticles2D.emitting = true
	set_physics_process( false )

func can_place_on( body: PhysicsBody2D ):
	return body.is_in_group( "breakables" )

func _on_Area2D_body_entered( body ):
	if not game.is_running or not ( body == game.player ):
		return
	
	queue_free()
