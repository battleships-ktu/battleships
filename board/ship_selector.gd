extends Sprite2D

var board
var ship

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = ship.texture

func set_ship(ship):
	self.ship = ship

func set_board(board):
	self.board = board

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var grid_pos = board.get_tile_grid_position(mouse_pos)
	
	if grid_pos != null:
		position = board.get_tile_global_position(grid_pos)
	else:
		position = mouse_pos
