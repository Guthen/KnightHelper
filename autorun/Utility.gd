extends Node

var levels = []
var items = {}

func _ready():
	#  read levels
	print( "Listing levels:" )
	for path in list_files( "res://map/levels/", ".tscn" ):
		levels.append( load( path ) )
		print( "%d ─ '%s'" % [len( levels ) - 1, path] )
	
	#  read items
	print( "\nListing items:" )
	for path in list_files( "res://game/items/", ".tres", true ):
		items[path.get_file().replace( ".tres", "" )] = load( path )
		print( "%d ─ '%s'" % [len( items ) - 1, path] )
	print()


func list_files( path: String, extension: String = "", recursive: bool = false ) -> Array:
	var dir = Directory.new()
	
	if not ( dir.open( path ) == OK ):
		return []
	
	#  read levels files
	dir.list_dir_begin()
	
	var files = []
	var file = dir.get_next()
	while not ( file == "" ):
		if not file.begins_with( "." ):
			if dir.current_is_dir() and recursive:
				files.append_array( list_files( path + file + "/", extension, true ) )
			if file.ends_with( extension ): 
				files.append( path + file )
				#print( "%d ─ %s" % [len( levels ) - 1, file] )
		file = dir.get_next()
	
	dir.list_dir_end()
	
	return files
