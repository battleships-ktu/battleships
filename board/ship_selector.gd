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

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = ship.texture
	transform = ship.transform
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
	BOARD_Y_LIMIT = board.HEIGTH - 1 + board_y_limit_offset
	
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
		var ship_grid_pos = grid_pos - Vector2i(ship_half_width, ship_half_height)
		#print(ship_grid_pos.x, " ", ship_grid_pos.y)
	else:
		position = mouse_pos


#TODO test code - will remove later
func _input(event):
	# Check if the event is a mouse button press event and if it's the right mouse button
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		rotate_ship()
		

#TODO move out (probably)
func rotate_ship():
	print("rotated")
	var swap = ship_width
	ship_width = ship_height
	ship_height = swap
	print(ship_width, ship_height)
	rotation_degrees += 90
	calc_offsets()
