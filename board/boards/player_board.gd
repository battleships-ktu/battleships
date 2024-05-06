extends Node2D
var tog_explosions
var tile_size
var EFFECT
var bomb_explosion
var water_explosion
var main_explosion
var tiles
var indicator
var ship_array = []
const WIDTH = 10
const HEIGHT = 10
var show_indicator = true

# Called when the node enters the scene tree for the first time.
func _ready():
	tiles = $Tiles
	instantiate_ship_array()
	
	for i in HEIGHT:
		print(ship_array[i])
	print()
	
	tog_explosions = 0
	
	set_process_input(true)
	bomb_explosion = preload("res://particles/Retro_Explosion.tscn");
	water_explosion = preload("res://particles/water_exoplosion.tscn");
 	#effect = EFFECT.instance();
	
	#level_scene.add_child(new_particles)
	indicator = $Indicator
	tile_size = tiles.tiles.tile_set.tile_size
	

func _show_bomb_explosion(mouse_position, type_explosive):
	if type_explosive == null:
		return
	var explosion = type_explosive.instantiate()
	add_child(explosion)
	explosion.emitting = true
	explosion.position = mouse_position


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_UP:
			tog_explosions=(tog_explosions+1) % 3
		match tog_explosions:
			0:
				main_explosion=null
			1:
				main_explosion=bomb_explosion
			2:
				main_explosion=water_explosion


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if show_indicator:
		update_indicator()


#sphagetti mama mia
func spawn_ship(ship):
	ship.position = to_local(ship.global_position)
	ship.transform = ship.global_transform
	add_child(ship)


func update_indicator():
	var mouse_position = get_viewport().get_mouse_position()
	var grid_coords = get_tile_grid_position(mouse_position)
	
	if grid_coords != null:
		indicator.visible = true
		indicator.position = to_local(tiles.get_tile_global_position(grid_coords))

		_show_bomb_explosion(indicator.position, main_explosion)

	else:
		indicator.visible = false


func instantiate_ship_array():
	for i in HEIGHT:
		var row = []
		row.resize(WIDTH)
		row.fill(0)
		ship_array.append(row)


func get_tile_grid_position(mouse_position):
	return tiles.get_tile_grid_position(mouse_position)


func get_tile_global_position(grid_position):
	return tiles.get_tile_global_position(grid_position)
	
# Sita visa funkcija yra belekoks hackas ir man cia niekas nepatinka
# bet jei norim speti viska padaryt tures jum tikt >:)
func set_ships_from_grid(grid):
	ship_array = grid
	
	print(grid)
	print()
	
	var battleship = preload("res://board/ships/battleship.tscn").instantiate()
	var carrier = preload("res://board/ships/carrier.tscn").instantiate()
	var cruiser = preload("res://board/ships/cruiser.tscn").instantiate()
	var patrol = preload("res://board/ships/patrol.tscn").instantiate()
	var placed = [true, false, false, false, false]
	
	for x in WIDTH:
		for y in HEIGHT:
			match grid[y][x]:
				1:
					if placed[1]:
						continue
					# Tikrinti rotacija
					if x + 1 < WIDTH && grid[y][x + 1] == 1:
						create_ship(battleship, 1, x, y, true)
					else:
						create_ship(battleship, 1, x, y, false)
					placed[1] = true
				2:
					if placed[2]:
						continue
					if x + 2 < WIDTH && grid[y][x + 2] == 2:
						create_ship(carrier, 2, x, y, true)
					else:
						create_ship(carrier, 2, x, y, false)
					placed[2] = true
				3:
					if placed[3]:
						continue
					if x + 1 < WIDTH && grid[y][x + 1] == 3:
						create_ship(cruiser, 3, x, y, true)
					else:
						create_ship(cruiser, 3, x, y, false)
					placed[3] = true
				4:
					if placed[3]:
						continue
					create_ship(patrol, 4, x, y, false)
					placed[3] = true

func create_ship(ship, ship_id, x, y, rotated):
	var new_ship = Sprite2D.new()
	new_ship.texture = ship.texture
	new_ship.transform = ship.transform
	new_ship.global_position = translate_grid_coords_to_scene(ship_id, rotated, x, y)
	new_ship.rotation = 0 if !rotated else PI / 2
	add_child(new_ship)

# Cia crazy blogas kodas, bet as niekaip negalejau gauti laivu width ir height
# tai tiesiog hardcodinau offsetus
func translate_grid_coords_to_scene(ship_id, rotated, x, y):
	var ship_offsets = [
		null,
		Vector2(tile_size.x / 2, tile_size.y * 2.5),
		Vector2(tile_size.x, tile_size.y * 2),
		Vector2(tile_size.x / 2, tile_size.y * 2),
		Vector2(tile_size.x / 2, tile_size.y / 2.5)
	]
	if !rotated:
		return Vector2(
			tile_size.x * (x + 1), 
			tile_size.y * (y + 1)
		) + ship_offsets[ship_id]
	return Vector2(
		tile_size.x * (x + 1) + ship_offsets[ship_id].y, 
		tile_size.y * (y + 1) + ship_offsets[ship_id].x
	)
