extends Control
var time := 0.18
var menu_posituion := Vector2.ZERO
var menu_size := Vector2.ZERO
var current_menu
var menu_stackii := []
@onready var menu_1 = $Menu
@onready var menu_2 = $Options
#@onready var tween = create_tween()
func _ready() -> void:
	#get_tree().change_scene_to_file("res://menus/options_menu.tscn")
	menu_posituion = Vector2(0,0)
	menu_size = get_viewport_rect().size
	current_menu = menu_1


func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://board/pre_battle.tscn")
	
func _on_back_pressed():
	move_to_prev()


func _on_options_pressed():
	move_to_next("menu_2")


func _on_exit_pressed():
	get_tree().quit()


func move_to_next(next_menu_id: String):
	var tween = create_tween()
	var next_menu = get_menu_id(next_menu_id)
	tween.tween_property(current_menu,"global_position",Vector2(-menu_size.x,0), time)
	tween.tween_property(next_menu,"global_position",menu_posituion, time)
	menu_stackii.append(current_menu)
	current_menu = next_menu

func move_to_prev():
	var prev_menu = menu_stackii.pop_back()

	if prev_menu != null:
			var tween = create_tween()
			tween.tween_property(current_menu,"global_position",Vector2(menu_size.x,0), time)
			tween.tween_property(prev_menu,"global_position",menu_posituion, time)
			current_menu = prev_menu

func get_menu_id(menu_id: String) -> Container:
	match menu_id:
		"menu_1":
			return menu_1
		"menu_2":
			return menu_2
		_:
			return menu_1
