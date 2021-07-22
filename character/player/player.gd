extends "res://character/character.gd"

func _ready():
	stop_target_dist_sqr = 2

#func get_movement_direction() -> Vector2:
#	var dir = Vector2()
#
##	if Input.is_action_pressed( "up" ):
##		dir.y -= 1
##	if Input.is_action_pressed( "down" ):
##		dir.y += 1
##	if Input.is_action_pressed( "left" ):
##		dir.x -= 1 
##	if Input.is_action_pressed( "right" ):
##		dir.x += 1
#
#	return dir

func _process( dt ):
	if not game.is_running:
		return
	
	var res = get_nearest_item()
	if game.door.position.distance_squared_to( position ) < res[1]:
		target = game.door
		return
	
	target = res[0]

func get_nearest_item():
	var nearest_dist = INF
	var nearest_item = null
	 
	for item in get_tree().get_nodes_in_group( "placeable" ):
		if not item.is_friendly:
			continue
		
		if "is_activated" in item and item.is_activated:
			continue
		
		var dist = item.position.distance_squared_to( position )
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_item = item
	
	return [nearest_item, nearest_dist]

func _input( event ):
	if event is InputEventMouseButton:
		if game.is_running and event.pressed and event.button_index == BUTTON_LEFT:
			attack_at( get_global_mouse_position() )

func _on_Player_on_take_damage( damage: int, velocity: Vector2 ):
	if health <= 0:
		game.set_pause( true )
		game.camera.target = self
		game.camera.desired_zoom *= .75
		game.anim_player.play( "fade_out" )
