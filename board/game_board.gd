extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_grid = $PlayerBoard/PlayerTileMap
	var indicator = $PlayerBoard/Indicator
	
	var mouse_pos = get_viewport().get_mouse_position()
	
	var grid_coords = player_grid.get_tile_coords(mouse_pos)
	
	if !(grid_coords.x == -1 || grid_coords.y == -1):
		indicator.visible = true
		indicator.position = player_grid.get_global_coords(grid_coords)
	else:
		indicator.visible = false
