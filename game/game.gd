extends Node2D

export var is_running: bool = false setget set_running
export var level_id: int = 0

onready var viewport_size = get_viewport_rect().size

var levels = []
var items = []
var current_items = {}
var slots_by_items = {}
var holding_item
var holding_item_id

func _ready():
	$Interface/InventoryPanel/Slot.visible = false
	
	#  change level
	change_level( level_id )

func _process( dt ):
	if holding_item:
		holding_item.position = get_global_mouse_position() + Utility.items[holding_item_id].offset

func _on_RunButton_pressed():
	set_running( not is_running )

func set_running( value: bool ):
	is_running = value
	if is_running:
		$Interface/AnimationPlayer.play( "hide" )
	else:
		$Interface/AnimationPlayer.play( "show" )

func change_level( level_id ) -> bool:
	#  delete last level
	var last_level_node = get_node( "Level" )
	if last_level_node:
		last_level_node.queue_free()
	
	if not Utility.levels[level_id]:
		print( "Can't find level %d!" % level_id )
		return false
	
	#  instance new level
	var new_level = Utility.levels[level_id].instance()
	add_child( new_level )
	
	self.level_id = level_id
	print( "Changed to level %d!" % level_id )
	
	#  setup items
	for item in new_level.start_items:
		current_items[item] = new_level.start_items[item]
	
	setup_inventory_ui()
	
	return true

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

func on_button_down( item ):
	if is_running or current_items[item] <= 0:
		return
	
	#  instance scene
	holding_item = Utility.items[item].scene.instance()
	holding_item_id = item
	add_child( holding_item )
	
	#  decrease by one
	current_items[item] -= 1
	slots_by_items[item].get_node( "CountLabel" ).text = str( current_items[item] )

func on_button_up( item ):
	if is_running:
		return
	
	if holding_item:
		#holding_item.queue_free()
		holding_item = null
		holding_item_id = null
