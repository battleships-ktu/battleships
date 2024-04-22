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
const HEIGTH = 10
var show_indicator = true

# Called when the node enters the scene tree for the first time.
func _ready():
	tiles = $Tiles
	instantiate_ship_array()
	
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
	for i in HEIGTH:
		var row = []
		row.resize(WIDTH)
		row.fill(0)
		ship_array.append(row)


func get_tile_grid_position(mouse_position):
	return tiles.get_tile_grid_position(mouse_position)


func get_tile_global_position(grid_position):
	return tiles.get_tile_global_position(grid_position)
