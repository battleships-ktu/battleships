extends Node2D
var tog_explosions
var tile_size
var EFFECT
var bomb_explosion
var water_explosion
var main_explosion
var tiles
var indicator
var hit_array = []
const WIDTH = 10
const HEIGHT = 10
var show_indicator = true
var enable_explosion = true

signal strike(Vector2i)

# Called when the node enters the scene tree for the first time.
func _ready():
	tiles = $Tiles
	instantiate_hit_array()

	indicator = $Indicator
	tile_size = tiles.tiles.tile_set.tile_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if show_indicator:
		update_indicator()
		

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_position = get_viewport().get_mouse_position()
			var grid_coords = get_tile_grid_position(mouse_position)
			if grid_coords == null:
				return
			if hit_array[grid_coords.y][grid_coords.x] == 0:
				strike.emit(grid_coords)


func hit_tile(coords):
	var marker = preload("res://board/boards/tokens/hit.tscn").instantiate()
	marker.position = to_local(get_tile_global_position(coords))
	hit_array[coords.y][coords.x] = 1
	add_child(marker)


func miss_tile(coords):
	var marker = preload("res://board/boards/tokens/miss.tscn").instantiate()
	marker.position = to_local(get_tile_global_position(coords))
	hit_array[coords.y][coords.x] = 2
	add_child(marker)


func update_indicator():
	var mouse_position = get_viewport().get_mouse_position()
	var grid_coords = get_tile_grid_position(mouse_position)
	
	if grid_coords != null:
		indicator.visible = true
		indicator.position = to_local(tiles.get_tile_global_position(grid_coords))
	else:
		indicator.visible = false


func instantiate_hit_array():
	for i in HEIGHT:
		var row = []
		row.resize(WIDTH)
		row.fill(0)
		hit_array.append(row)


func get_tile_grid_position(mouse_position):
	return tiles.get_tile_grid_position(mouse_position)


func get_tile_global_position(grid_position):
	return tiles.get_tile_global_position(grid_position)
