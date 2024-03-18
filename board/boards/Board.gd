extends Node2D

var tiles

# Called when the node enters the scene tree for the first time.
func _ready():
	tiles = $GridTiles

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_tile_grid_position(global_position):
	return tiles.get_tile_grid_position(global_position)

	
func get_tile_global_position(grid_position):
	return to_global(tiles.get_tile_local_position(grid_position))
