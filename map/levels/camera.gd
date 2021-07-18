extends Camera2D

var desired_zoom: Vector2
var target: Node2D

func _ready():
	desired_zoom = zoom

func _process( dt ):
	if target and weakref( target ).get_ref():
		position = target.position
	
	if smoothing_enabled:
		zoom = Vector2( lerp( zoom.x, desired_zoom.x, dt * smoothing_speed ), lerp( zoom.y, desired_zoom.y, dt * smoothing_speed ) )
