extends Node2D

export var is_running: bool = false
export var level_id: int = 0

var levels = []
var items = []
var current_items = {}

func _ready():
	
	
	#  change level
	change_level( level_id )


func _on_RunButton_pressed():
	is_running = true

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
	for item in current_items:
		pass
