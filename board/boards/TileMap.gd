extends TileMap

const WIDTH = 10
const HEIGHT = 10
	
func get_tile_coords(mouse_coords):
	var grid_coords = local_to_map(self.to_local(mouse_coords))
	if grid_coords.x < 0 || grid_coords.x >= WIDTH || grid_coords.y < 0 || grid_coords.y >= HEIGHT:
		return Vector2i(-1, -1)
	return grid_coords

func get_global_coords(tile_coords):
	return Vector2i(map_to_local(tile_coords))
