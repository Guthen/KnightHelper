extends Node

var current_level_id: int = 0
var levels = []
var items = {}

var hurt_sounds = [
	preload( "res://assets/sounds/hurt01.wav" ),
	preload( "res://assets/sounds/hurt02.wav" ),
	preload( "res://assets/sounds/hurt03.wav" ),
]

var explosion_sounds = [
	preload( "res://assets/sounds/explosion01.wav" ),
	preload( "res://assets/sounds/explosion02.wav" ),
]

var select_sounds = [
	preload( "res://assets/sounds/select01.wav" ),
	preload( "res://assets/sounds/select02.wav" ),
]

var font = DynamicFont.new() 

func _ready():
	#  font
	font.font_data = load( "res://assets/vkx_pixel.ttf" )
	font.size = 12
	
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
