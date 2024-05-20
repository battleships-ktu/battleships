extends Node2D

@onready var board = $PlayerBoard
@onready var global_node = get_node("/root/Global")

var is_selecting_ship = false
var selected_ship
var selected_ship_id
var saved_button
var ships_left = 4
var last_click_time = 0.0
var double_click_threshold = 0.3  # Adjust this value to your needs

func _input(event):
	
	if not selected_ship:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_click_time < double_click_threshold:
			# Detected a double click
			board.enable_explosion = false
			selected_ship.rotate_ship()
		last_click_time = current_time
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		board.enable_explosion = false
		if selected_ship.try_place_ship(selected_ship, selected_ship_id):
			detach_ship_from_mouse()
			ships_left -= 1
			if ships_left == 0:
				$Control/StartGameButton.disabled = false


func _on_ready():
	global_node.reset()


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
	var global_node = get_node("/root/Global")
	global_node.ship_grid = board.ship_array
	#global_node.enable_explosion = true
	get_tree().change_scene_to_file("res://board/game_board.tscn")



func _on_battleship_button_pressed():
	#board.enable_explosion = true
	var ship = preload("res://board/ships/battleship.tscn").instantiate()
	selected_ship_id = 1
	attach_ship_to_mouse(ship, $Control/Panel/MarginContainer/ShipButtonContainer/BattleshipButton)


func _on_carrier_button_pressed():
	var ship = preload("res://board/ships/carrier.tscn").instantiate()
	selected_ship_id = 2
	attach_ship_to_mouse(ship, $Control/Panel/MarginContainer/ShipButtonContainer/CarrierButton)


func _on_cruiser_button_pressed():
	var ship = preload("res://board/ships/cruiser.tscn").instantiate()
	selected_ship_id = 3
	attach_ship_to_mouse(ship, $Control/Panel/MarginContainer/ShipButtonContainer/CruiserButton)


func _on_patrol_button_pressed():
	var ship = preload("res://board/ships/patrol.tscn").instantiate()
	selected_ship_id = 4
	attach_ship_to_mouse(ship, $Control/Panel/MarginContainer/ShipButtonContainer/PatrolButton)
