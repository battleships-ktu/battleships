extends Node2D

@onready var board = $PlayerBoard

var is_selecting_ship = false
var selected_ship
var saved_button


func _input(event):
	if not selected_ship:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		selected_ship.rotate_ship()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if selected_ship.try_place_ship(selected_ship):
			detach_ship_from_mouse()


func attach_ship_to_mouse(ship, button):
	if is_selecting_ship:
		detach_ship_from_mouse()
		saved_button.show()
	is_selecting_ship = true
	saved_button = button
	button.hide()
	
	selected_ship = instantiate_mouse_ship(ship)
	board.show_indicator = false
	add_child(selected_ship)

func instantiate_mouse_ship(ship):
	var mouse_ship = Sprite2D.new()
	var script = preload("res://board/ship_selector.gd")
	
	mouse_ship.set_script(script)
	mouse_ship.board = board
	mouse_ship.ship = ship
	mouse_ship.set_process(true)
	return mouse_ship


func detach_ship_from_mouse():
	selected_ship.queue_free()
	is_selecting_ship = false
	board.show_indicator = true


func _on_start_game_button_pressed():
	var global = get_node("/root/Global")
	global.player_board = PackedScene.new()
	global.player_board.pack(get_node("PlayerBoard"))
	get_tree().change_scene_to_file("res://board/game_board.tscn")


func _on_battleship_button_pressed():
	var ship = preload("res://board/ships/battleship.tscn").instantiate()
	attach_ship_to_mouse(ship, $ShipButtonContainer/BattleshipButton)


func _on_carrier_button_pressed():
	var ship = preload("res://board/ships/carrier.tscn").instantiate()
	attach_ship_to_mouse(ship, $ShipButtonContainer/CarrierButton)


func _on_cruiser_button_pressed():
	var ship = preload("res://board/ships/cruiser.tscn").instantiate()
	attach_ship_to_mouse(ship, $ShipButtonContainer/CruiserButton)


func _on_patrol_button_pressed():
	var ship = preload("res://board/ships/patrol.tscn").instantiate()
	attach_ship_to_mouse(ship, $ShipButtonContainer/PatrolButton)
