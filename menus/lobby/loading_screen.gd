extends Node
const HOST: String = "localhost"
const PORT: int = 24845
var UID = ""
var EXIT = false

@onready
var _client = get_node("/root/TCPClient")
var lastData: PackedStringArray


func _ready() -> void:
	_client.connected.connect(_handle_client_connected)
	_client.disconnected.connect(_handle_client_disconnected)
	_client.errored.connect(_handle_client_error)
	_client.response.connect(_handle_client_data)
	
	_connect()

func _get_list_of_rooms():
	if !_client.is_online():
		return
		
	_client.send("0;%d;0" % _client.PROTOCOL_VERSION)
	await _client.response
	#print("Handshake response: ", lastData)
	_client.send("0")
	await _client.response
	print("Empty rooms: ", lastData)
	
	if lastData[1] != "":
			print("Theres a room ", lastData[1])
			UID = lastData[1]
	else:
		UID = null

func _handle_client_data(data: Array) -> void:
	lastData = data

		
func _create_room():
	if !_client.is_online():
		return
		
	_client.send("0;%d;0" % _client.PROTOCOL_VERSION)
	await _client.response
	#print("Handshake response: ", lastData)
	_client.send("0")
	await _client.response
	print("Empty rooms: ", lastData)
	
func _login():
	if !_client.is_online():
		return
		
	_client.send("0;%d;1" % _client.PROTOCOL_VERSION)
	await _client.response
	#print("Handshake response: ", lastData)
	_client.send("0;Test name")
	await _client.response
	print("Login response: ", lastData)


func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")
	if ! EXIT:
		_connect()


func _handle_client_error() -> void:
	print("Client err.")

func _handle_client_connected() -> void:
	print("Client connected to server.")
	
	if UID == "":
		_get_list_of_rooms()
		
	elif UID == null:
		print("trying to login")
		_login()
		print("Creating room ")
		_create_room()
	else:
		_login()
		_join_room(UID)
		
func _connect():
	_client.connect_to_host(HOST, PORT)
	
func _join_room(UIID: String):
	if !_client.is_online():
		return		
	# Serveriui duodamas room UID prie kurio prisijungti
	_client.send("1;%s" % UIID)
	await _client.response
	print("Game start response main: ", lastData[0])
	#print(lastData)
	if int(lastData[0]) == 0:
		print("GAME STARTED")
		get_tree().change_scene_to_file("res://board/game_board.tscn")
		#game_state = GameState.AWAIT_ATTACK

func _process(delta):
	pass

func _on_cancel_pressed():
	EXIT=true
	get_tree().change_scene_to_file("res://menus/menu.tscn")
