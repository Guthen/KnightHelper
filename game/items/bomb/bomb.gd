extends "res://game/items/scn_placeable_item.gd"


func _ready():
	pass

func _on_Area2D_body_entered( body ):
	if not ( body == game.player ):
		return
	
	queue_free()
