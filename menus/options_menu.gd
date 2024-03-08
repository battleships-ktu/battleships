extends Control



@export
var bus_name: String

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
		

func _on_back_pressed():
	get_tree().change_scene_to_file("res://menus/menu.tscn")
