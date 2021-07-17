extends Node2D

export var is_running: bool = false
export var level_id: int = 0
export var levels_path: String = "res://map/levels/"

var levels = []

func _ready():
	var dir = Directory.new()
	
	if not ( dir.open( levels_path ) == OK ):
		return print( "Can't read levels!" )
	
	#  read levels files
	print( "Listing levels:" )
	dir.list_dir_begin()
	
	var file = dir.get_next()
	while not ( file == "" ):
		if not file.begins_with( "." ): 
			levels.append( load( levels_path + file ) )
			print( "%d ─ %s" % [len( levels ) - 1, file] )
		file = dir.get_next()
	
	dir.list_dir_end()
	
	#  change level
	change_level( level_id )


func _on_RunButton_pressed():
	is_running = true

func change_level( level_id ) -> bool:
	#  delete last level
	var last_level_node = get_node( "Level" )
	if last_level_node:
		last_level_node.queue_free()
	
	if not levels[level_id]:
		print( "Can't find level %d!" % level_id )
		return false
	
	#  instance new level
	var new_level = levels[level_id].instance()
	add_child( new_level )
	
	self.level_id = level_id
	print( "Changed to level %d!" % level_id )
	return true
