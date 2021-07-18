extends Camera2D

var desired_zoom: Vector2

func _ready():
	desired_zoom = zoom

func _process( dt ):
	if smoothing_enabled:
		zoom = Vector2( lerp( zoom.x, desired_zoom.x, dt * smoothing_speed ), lerp( zoom.y, desired_zoom.y, dt * smoothing_speed ) )
