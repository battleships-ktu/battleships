extends Node

#var URL ="http://127.0.0.1:24845"
var URL ="http://localhost:24845"
#var URL ="https://httpbin.org/get"
func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request(URL)

func _on_request_completed(result, response_code, headers, body):
#var output= body.get_string_from_utf8()
	var json = JSON.parse_string(body.get_string_from_utf8())
#print(json["type"])
	print(json)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_cancel_pressed():
	get_tree().change_scene_to_file("res://menus/menu.tscn")
