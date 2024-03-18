extends Node2D

var board
var indicator

# Called when the node enters the scene tree for the first time.
func _ready():
	board = $PlayerBoard/Board/GridTiles
	indicator = $PlayerBoard/Board/Indicator


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_position = 
	var grid_coords = get_mouse_grid_position()
	var indicator = $PlayerBoard/Indicator
	
	if !(grid_coords.x == -1 || grid_coords.y == -1):
		indicator.visible = true
		indicator.position = board.get_global_coords(grid_coords)
	else:
		indicator.visible = false


func get_mouse_grid_position(mouse_position):
	var player_grid = $Board/GridTiles
	return player_grid.get_tile_coords(mouse_position)
	

