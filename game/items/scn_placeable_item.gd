extends Node2D

export var is_placeable: bool = true
export var is_pickable: bool = false
export var hovered_color: Color = Color8( 255, 255, 255, 225 )
export var can_place_on_floor: bool = true
export var reset_z_index: bool = true
export var item_id: String

onready var game = get_node( "/root/Game" )
onready var default_color = $HaloSprite.modulate

var is_hovered = false
var is_position_cleared = true

func _ready():
	pass

func _process( dt ):
	$HaloSprite.visible = is_placeable and not game.is_running
	if is_placeable:
		$HaloSprite.rotation_degrees = fmod( game.time * 50, 360 )
		$HaloSprite.modulate = hovered_color if is_hovered else default_color

func can_place_on( body: PhysicsBody2D ):
	return false

func _on_MouseCollision_mouse_entered():
	is_hovered = true

func _on_MouseCollision_mouse_exited():
	is_hovered = false
