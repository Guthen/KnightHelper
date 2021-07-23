extends "res://character/character.gd"

func _ready():
	pass

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
	
	if not is_idle:
		return
	
	var item_res = get_nearest_item()
	var can_access_to_item = false
	if item_res[0]:
		can_access_to_item = find_path( item_res[0].position )
	
	#  attack nearest enemy
	if weapon_data:
		var enemy_res = get_nearest_enemy()
		if enemy_res[0] and ( not can_access_to_item or enemy_res[1] < item_res[1] ):
			stop_target_dist_sqr = default_stop_target_dist_sqr
			if find_path( enemy_res[0].position ):
				target = enemy_res[0]
			return
	
	#  go to door
	stop_target_dist_sqr = 0
	if not can_access_to_item or game.door.position.distance_squared_to( position ) < item_res[1]:
		if find_path( game.door.position ):
			target = game.door
			path.remove( len( path ) - 1 )
		return
	
	#  go to the item
	target = item_res[0]

func on_stop_target():
	if is_freezed:
		return
	
	if target is Character:
		attack_at( target.global_position )

func get_nearest_enemy():
	var nearest_dist = INF
	var nearest_enemy = null
	 
	for enemy in get_tree().get_nodes_in_group( "enemies" ):
		var dist = enemy.position.distance_squared_to( position )
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_enemy = enemy
	
	return [nearest_enemy, nearest_dist]

func get_nearest_item():
	var nearest_dist = INF
	var nearest_item = null
	 
	for item in get_tree().get_nodes_in_group( "placeables" ):
		if not item.is_pickable:
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

func on_take_damage( damage: int, velocity: Vector2 ):
	if health <= 0:
		game.set_pause( true )
		game.camera.target = self
		game.camera.desired_zoom *= .75
		game.anim_player.play( "fade_out" )
