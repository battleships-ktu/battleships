extends Sprite2D

var board
var ship

var ship_grid_position

var BOARD_X_LIMIT
var BOARD_Y_LIMIT
var BOARD_HALF_TILE

var ship_width
var ship_height
var ship_half_width
var ship_half_height

var position_offset
#var _old_transfrom #hacky terrible solution, but i don't care

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = ship.texture
	transform = ship.transform
	scale *= board.scale
	ship_width = ship.get_meta("Width")
	ship_height = ship.get_meta("Height")
	BOARD_HALF_TILE = board.tile_size / 2
	calc_offsets()


func calc_offsets():
	ship_half_width = ship_width / 2
	ship_half_height = ship_height / 2
	
	#Board limit offsets for non-odd size ships
	var board_x_limit_offset = 1 - ship_width % 2
	var board_y_limit_offset = 1 - ship_height % 2
	BOARD_X_LIMIT = board.WIDTH - 1 + board_x_limit_offset
	BOARD_Y_LIMIT = board.HEIGHT - 1 + board_y_limit_offset
	
	position_offset = Vector2(
		BOARD_HALF_TILE.x * board_x_limit_offset,
		BOARD_HALF_TILE.y * board_y_limit_offset
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var grid_pos = board.get_tile_grid_position(mouse_pos)
	
	if grid_pos != null:
		#Limit X
		if grid_pos.x - ship_half_width < 0:
			grid_pos.x = ship_half_width
		elif grid_pos.x + ship_half_width > BOARD_X_LIMIT:
			grid_pos.x = BOARD_X_LIMIT - ship_half_width
		
		#Limit Y
		if grid_pos.y - ship_half_height < 0:
			grid_pos.y = ship_half_height
		elif grid_pos.y + ship_half_height > BOARD_Y_LIMIT:
			grid_pos.y = BOARD_Y_LIMIT - ship_half_height
		
		position = board.get_tile_global_position(grid_pos) - position_offset

		#Coordinates for the top-left corner of the ship
		ship_grid_position = grid_pos - Vector2i(ship_half_width, ship_half_height)
		#print(ship_grid_pos.x, " ", ship_grid_pos.y)
	else:
		position = mouse_pos
		ship_grid_position = null


func try_place_ship(ship_selector, shipId):
	if ship_selector.ship_grid_position == null:
		return
		
	var ship_width = ship_selector.ship_width
	var ship_height = ship_selector.ship_height
	var target_x = ship_selector.ship_grid_position.x
	var target_y = ship_selector.ship_grid_position.y
	
	#Check if ship can be placed
	for ship_row in ship_height:
		for ship_col in ship_width:
			if board.ship_array[ship_row + target_y][ship_col + target_x] != 0:
				return false
	
	#Spawn ship: Set flags in ship matrix
	for ship_row in ship_height:
		for ship_col in ship_width:
			board.ship_array[ship_row + target_y][ship_col + target_x] = shipId
			
	for y in 10:
		print(board.ship_array[y])
	print()
	
	#Spawn ship: create ship sprite (košė makalošė, bet idc)
	var new_ship = Sprite2D.new()
	new_ship.texture = ship.texture
	new_ship.transform = ship.transform
	new_ship.global_position = ship_selector.global_position
	new_ship.rotation = ship_selector.rotation
	board.spawn_ship(new_ship)
	return true


#TODO move out (probably)
func rotate_ship():
	print("rotated")
	var swap = ship_width
	ship_width = ship_height
	ship_height = swap
	print(ship_width, ship_height)
	rotation_degrees += 90
	calc_offsets()
