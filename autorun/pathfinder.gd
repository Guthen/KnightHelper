extends Node2D

#export (String) var tilemap_name = "FloorMap"
export (Dictionary) var tile_index_cost = {} 
export (bool) var debug = false

var astar = AStar2D.new()
var tilemap: TileMap
var cell_size: Vector2
var used_rect: Rect2
var tiles: Array

func init( tilemap: TileMap ):
	init_navigation_map( tilemap )

func init_navigation_map( tilemap: TileMap = self.tilemap ):
	#  init values
	self.tilemap = tilemap
	cell_size = tilemap.cell_size
	used_rect = tilemap.get_used_rect()
	
	#  load tilemap
	var tiles = tilemap.get_used_cells()
	
	astar.clear()
	astar.reserve_space( used_rect.size.x * used_rect.size.y )
	
	add_tiles( tiles )
	connect_tiles( tiles )
	compute_temporary_obstacles( tiles )
	
	self.tiles = tiles
	update()

func compute_temporary_obstacles( tiles: Array = self.tiles ):
	var count = 0
	for obj in get_tree().get_nodes_in_group( "objects" ):
		for tile in tiles:
			var disabled = tilemap.world_to_map( obj.position ) == tile and not obj.is_queued_for_deletion()
			if disabled:
				print( "Pathfinder: Object found at ", tile, ", tile disabled" )
				count += 1
			
			astar.set_point_disabled( astar.get_closest_point( tile ), disabled )
	
	print( "Pathfinder: Computed %d obstacles." % count )

func add_tiles( tiles: Array = self.tiles ):
	for tile in tiles:
		var id = get_point_id( tile )
		#print( id, " ", tilemap.get_cellv( tile ) )
		astar.add_point( id, tile )

var neighboor_range = [-1, 0, 1]
func connect_tiles( tiles: Array = self.tiles ):
	for tile in tiles:
		var id = get_point_id( tile )
		for x in neighboor_range:
			for y in neighboor_range:
				if x == 0 and y == 0:
					continue
				
				var pos = Vector2( tile.x + x, tile.y + y )
				if tilemap.get_cellv( pos ) == -1:
					continue
				
				if not ( x == 0 ) and not ( y == 0 ):
					if tilemap.get_cellv( tile + Vector2( x, 0 ) ) == -1:
						continue
					if tilemap.get_cellv( tile + Vector2( 0, y ) ) == -1:
						continue
				
				var neigh_id = get_point_id( pos )
				if astar.has_point( neigh_id ):
					astar.connect_points( id, neigh_id, true )

func get_point_id( pos: Vector2 ):
	var x = pos.x - used_rect.position.x
	var y = pos.y - used_rect.position.y
	
	return x * used_rect.size.y + y

func grid_to_world( pos: Vector2 ):
	return tilemap.map_to_world( pos ) + cell_size / 2

func get_closest_point( pos: Vector2 ):
	return grid_to_world( astar.get_point_position( astar.get_closest_point( tilemap.world_to_map( pos ) ) ) )

func find_path( start: Vector2, end: Vector2 ) -> PoolVector2Array:
	var grid_start = tilemap.world_to_map( start )
	var grid_end = tilemap.world_to_map( end ) 
	
	var start_id = astar.get_closest_point( grid_start ) #get_point_id( grid_start )
	var end_id = astar.get_closest_point( grid_end )#get_point_id( grid_end )
	
	var world_path = PoolVector2Array()
	
	#  check ids
	if not astar.has_point( start_id ) or not astar.has_point( end_id ):
		return world_path
	
	#  find path
	var path = astar.get_point_path( start_id, end_id )
	
	#  convert units from local to world
	for pos in path:
		world_path.append( grid_to_world( pos ) )

	return world_path


func _draw():
	if not debug:
		return
	
#	var drawn_ids = {}
	for tile in tiles:
		var id = get_point_id( tile )
		var disabled = astar.is_point_disabled( id )
#		if drawn_ids.get( id ):
#			print( "Pathfinder: ID: ", id, " is already drawn!" )
#			continue
#		drawn_ids[id] = true
		
		#  draw node
		var pos = tilemap.map_to_world( tile ) + cell_size / 2
		draw_circle( pos, 2, Color.red if disabled else Color.greenyellow )
		draw_string( Utility.font, pos, str( id ) )
		
		#  draw connections
		#var text = str( id ) + " -> "
		for neigh in astar.get_point_connections( id ):
			#text += str( neigh ) + ", "
			draw_line( pos, tilemap.map_to_world( astar.get_point_position( neigh ) ) + cell_size / 2, Color.greenyellow )
		#print( text )
