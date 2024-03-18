extends Node2D

var board
var indicator

# Called when the node enters the scene tree for the first time.
func _ready():
	board = $Board/GridTiles
	indicator = $Board/Indicator


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#todo move this out
	var mouse_position = get_viewport().get_mouse_position()
	var grid_coords = get_mouse_grid_position(mouse_position)
	
	if !(grid_coords.x == -1 || grid_coords.y == -1):
		indicator.visible = true
		indicator.position = board.get_global_coords(grid_coords)
	else:
		indicator.visible = false


func get_mouse_grid_position(mouse_position):
	var player_grid = $Board/GridTiles
	return player_grid.get_tile_coords(mouse_position)
