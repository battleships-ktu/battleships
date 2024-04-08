extends Node2D

var is_selecting_ship = false
var selected_ship
var saved_button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func attach_ship_to_mouse(ship, button):
	if is_selecting_ship:
		detach_ship_from_mouse()
		saved_button.show()
	is_selecting_ship = true
	saved_button = button
	button.hide()
	selected_ship = Sprite2D.new()
	var script = preload("res://board/ship_selector.gd")
	var board = $PlayerBoard
	selected_ship.set_script(script)
	selected_ship.set_board(board)
	selected_ship.set_ship(ship)
	selected_ship.set_process(true)
	add_child(selected_ship)

func detach_ship_from_mouse():
	selected_ship.queue_free()
	is_selecting_ship = false


func _on_start_game_button_pressed():
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
