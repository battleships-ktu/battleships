extends Node2D

var tiles
var indicator

# Called when the node enters the scene tree for the first time.
func _ready():
	tiles = $Tiles
	indicator = $Indicator


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_indicator()


func update_indicator():
	var mouse_position = get_viewport().get_mouse_position()
	var grid_coords = get_tile_grid_position(mouse_position)
	
	if grid_coords != null:
		indicator.visible = true
		indicator.position = to_local(tiles.get_tile_global_position(grid_coords))
		print(indicator.position)
	else:
		indicator.visible = false


func get_tile_grid_position(mouse_position):
	return tiles.get_tile_grid_position(mouse_position)


func get_tile_global_position(grid_position):
	return tiles.get_tile_global_position(grid_position)

