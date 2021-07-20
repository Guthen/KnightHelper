extends Node2D

export var is_running: bool = false setget set_running
export var level_id: int = 0

onready var viewport_size = get_viewport_rect().size

var level
var levels = []
var items = []
var current_items = {}
var slots_by_items = {}
var holding_item
var is_moving_item = false

var callback_object: Node
var callback_method: String

var time: float
var camera: Camera2D
var player: KinematicBody2D
var packed_scene: PackedScene
var last_pos: Vector2
var last_zoom: Vector2
var last_click_time: int
var is_paused: bool setget set_pause
onready var anim_player = $Interface/AnimationPlayer

func _ready():
	$Interface/InventoryPanel/Slot.visible = false
	
	#  change level
	change_level( level_id )

func _process( dt ):
	time += dt
	
	if holding_item:
		var pos = get_global_mouse_position()
		pos.x = floor( pos.x / 16 ) * 16 + 8
		pos.y = floor( pos.y / 16 ) * 16 + 8
		holding_item.position = pos + Utility.items[holding_item.item_id].offset

func _input( event ):
	if event is InputEventMouseButton:
		if not is_running and event.button_index == BUTTON_LEFT:
			if not holding_item and event.pressed:
				for placeable in get_tree().get_nodes_in_group( "placeable" ):
					if placeable.is_placeable and placeable.is_hovered:
						hold_item( placeable )
						is_moving_item = true
						break
			elif holding_item and not event.pressed and is_moving_item:
				drop_holding_item()
				is_moving_item = false
	if event is InputEventMouseMotion:
		if not is_running and holding_item:
			holding_item.get_node( "HaloSprite" ).self_modulate = Color.green if is_item_placeable( holding_item ) else Color.red

func set_running( value: bool, animate: bool = false ):
	if value:
		packed_scene = PackedScene.new()
		packed_scene.pack( get_node( "Level" ) )
		
		anim_player.play( "hide" )
	else:
		var level = get_node( "Level" )
		if level:
			level.free()
		if packed_scene:
			unpack_level( packed_scene, animate )
			packed_scene = null
		
		anim_player.play( "show" )
	
	is_running = value

func set_pause( value: bool ):
	for node in level.get_node( "WallMap" ).get_children():
		node.set_physics_process( not value ) 
	
	is_paused = value

func unpack_level( packed_scene, animate: bool = false ) -> Node:
	var new_level = packed_scene.instance()
	call_deferred( "add_child", new_level )
	
	level = new_level
	camera = new_level.get_node( "Camera" )
	player = new_level.get_node( "WallMap/Player" )
	
	#  animate camera
	if animate:
		last_pos = camera.position
		last_zoom = camera.zoom
		camera.smoothing_enabled = false
		camera.position = player.position
		camera.zoom *= .75
	
	return new_level

func change_level( level_id ) -> bool:
	#  delete last level
	var last_level_node = get_node( "Level" )
	if last_level_node:
		last_level_node.call_deferred( "free" )
	
	if level_id < 0 or level_id > len( Utility.levels ) - 1:
		print( "Can't find level %d!" % level_id )
		return false
	
	#  play fade
	anim_player.play( "fade_in" )
	is_paused = false
	is_running = false
	
	#  instance new level
	var new_level = unpack_level( Utility.levels[level_id], true )
	
	self.level_id = level_id
	print( "Changed to level %d!" % level_id )
	
	#  setup items
	for item in new_level.start_items:
		current_items[item] = new_level.start_items[item]
	
	setup_inventory_ui()
	
	return true

func fade_out( target: Node2D, object: Node = null, method: String = "" ):
	set_pause( true )
	camera.target = target
	camera.desired_zoom *= .75
	
	callback_object = object
	callback_method = method
	
	anim_player.play( "fade_out" )

func setup_inventory_ui():
	var i = $Interface/InventoryPanel.get_child_count() - 1
	for item in current_items:
		var slot = $Interface/InventoryPanel/Slot.duplicate()
		slot.rect_position.x = i * slot.rect_size.x
		slot.get_node( "CountLabel" ).text = str( current_items[item] )
		slot.visible = true
		$Interface/InventoryPanel.add_child( slot )
		
		var button = slot.get_node( "TextureButton" )
		button.texture_normal = Utility.items[item].texture
		button.connect( "button_down", self, "on_button_down", [item] )
		button.connect( "button_up", self, "on_button_up", [item] )
		
		slots_by_items[item] = slot
		i += 1
	
	$Interface/InventoryPanel.rect_size.x = i * $Interface/InventoryPanel/Slot.rect_size.x
	$Interface/InventoryPanel.rect_position.x = viewport_size.x / 2 - $Interface/InventoryPanel.rect_size.x / 2

func add_item_count( item_id, count ):
	current_items[item_id] = max( 0, current_items[item_id] + count )
	slots_by_items[item_id].get_node( "CountLabel" ).text = str( current_items[item_id] )

func delete_item( item ):
	item.queue_free()
	add_item_count( item.item_id, 1 )

func is_item_placeable( item: Node2D ):
	var floormap = level.get_node( "FloorMap" ) as TileMap
	if floormap.get_cellv( item.position / 16 ) < 0:
		return false
	
	for node in level.get_node( "WallMap" ).get_children():
		if node == item:
			continue
		
		if node is PhysicsBody2D and item.get_node( "MouseCollision" ).overlaps_body( node ):
			return false
		
		if "is_placeable" in node and item.get_node( "MouseCollision" ).overlaps_area( node.get_node( "MouseCollision" ) ):
			return false 
	
	return true

func hold_item( item ):
	item.z_index = 1
	holding_item = item

func drop_holding_item():
	holding_item.get_node( "HaloSprite" ).self_modulate = Color.white
	holding_item.z_index = 0
	
	if not is_item_placeable( holding_item ):
		delete_item( holding_item )
	
	holding_item = null

func on_button_down( item ):
	if is_running or current_items[item] <= 0:
		return
	
	#  instance scene
	holding_item = Utility.items[item].scene.instance()
	holding_item.is_hovered = true
	holding_item.item_id = item
	level.get_node( "WallMap" ).add_child( holding_item )
	holding_item.set_owner( level ) #  important: used to save it
	hold_item( holding_item )
	
	#  decrease by one
	add_item_count( item, -1 )

func on_button_up( item ):
	if is_running:
		return
	
	if holding_item:
		drop_holding_item()


func _on_RunButton_pressed():
	var cur_time = OS.get_unix_time()
	if cur_time - last_click_time < 1:
		return
		
	set_running( true )
	last_click_time = cur_time

func _on_StopButton_pressed():
	var cur_time = OS.get_unix_time()
	if cur_time - last_click_time < 1:
		return
	
	set_running( false )
	last_click_time = cur_time

func _on_AnimationPlayer_animation_finished( anim_name ):
	if anim_name == "fade_out":
		if callback_object:
			callback_object.call( callback_method )
		else:
			yield( get_tree().create_timer( .5 ), "timeout" )
			set_running( false, true )
			anim_player.play( "fade_in" )
	elif anim_name == "fade_in" && not camera.smoothing_enabled:
		camera.smoothing_enabled = true
		camera.position = last_pos
		camera.desired_zoom = last_zoom
		
		anim_player.play( "first_show" )
