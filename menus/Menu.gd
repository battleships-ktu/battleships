extends Control





func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://board/game_board.tscn")


func _on_options_pressed():
	get_tree().change_scene_to_file("res://menus/options_menu.tscn")
	


func _on_exit_pressed():
	get_tree().quit()

