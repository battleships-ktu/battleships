extends TileMap

const WIDTH = 10
const HEIGHT = 10


func get_tile_grid_position(mouse_coords):
	var grid_coords = local_to_map(self.to_local(mouse_coords))
	if grid_coords.x < 0 || grid_coords.x >= WIDTH || grid_coords.y < 0 || grid_coords.y >= HEIGHT:
		return null
	return grid_coords

func get_tile_local_position(tile_coords):
	return Vector2i((map_to_local(tile_coords)))
