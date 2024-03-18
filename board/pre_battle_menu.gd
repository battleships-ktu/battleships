extends Node2D

var is_selecting_ship = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func attach_ship_to_mouse(ship):
	if is_selecting_ship:
		return
	var ship_selector = Sprite2D.new()
	var script = preload("res://board/ship_selector.gd")
	var board = $PlayerBoard
	ship_selector.set_script(script)
	ship_selector.set_board(board)
	ship_selector.set_ship(ship)
	ship_selector.set_process(true)
	add_child(ship_selector)
	

func _on_start_game_button_pressed():
	get_tree().change_scene_to_file("res://board/game_board.tscn")


func _on_battleship_button_pressed():
	var ship = preload("res://board/ships/battleship.tscn").instantiate()
	attach_ship_to_mouse(ship)


func _on_carrier_button_pressed():
	var ship = preload("res://board/ships/carrier.tscn").instantiate()
	attach_ship_to_mouse(ship)


func _on_cruiser_button_pressed():
	var ship = preload("res://board/ships/cruiser.tscn").instantiate()
	attach_ship_to_mouse(ship)


func _on_patrol_button_pressed():
	var ship = preload("res://board/ships/patrol.tscn").instantiate()
	attach_ship_to_mouse(ship)
