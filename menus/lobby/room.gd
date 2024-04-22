extends Node
const HOST: String = "localhost"
const PORT: int = 24845
var No_ROOM = true
var True_exit = false
enum GameState {NOT_STARTED, ATTACK, AWAIT_ATTACK, AWAIT_RESPONSE, RESPOND, WINNER, LOSER}
@onready
var _client = $Client
var lastData: PackedStringArray
var game_state = GameState.NOT_STARTED
#var URL ="https://httpbin.org/get"
func _ready() -> void:
	#print(_client)

	# Debuging
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
	print("Handshake response: ", lastData)
	_client.send("0")
	await _client.response
	print("Empty rooms: ", lastData)
	if lastData[1] == "":
			No_ROOM = false
	else:
		print("Theres a room ", lastData[1])
		_on_join_room_pressed(lastData[1])

func _handle_client_data(data: Array) -> void:
	lastData = data
	if (game_state != GameState.NOT_STARTED):
		handle_game_response()
	# Joins the first room in the list
	#else:
		
func _on_create_room():
	if !_client.is_online():
		return
		
	_client.send("0;%d;0" % _client.PROTOCOL_VERSION)
	await _client.response
	print("Handshake response: ", lastData)
	_client.send("0")
	await _client.response
	print("Empty rooms: ", lastData)
	
func _login():
	if !_client.is_online():
		return
		
	_client.send("0;%d;1" % _client.PROTOCOL_VERSION)
	await _client.response
	print("Handshake response: ", lastData)
	_client.send("0;Test name")
	await _client.response
	print("Login response: ", lastData)
	



# Debuging 
func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")
	if ! True_exit:
		_connect()

	
func _handle_client_error() -> void:
	print("Client err.")

func _handle_client_connected() -> void:
	print("Client connected to server.")
	
	if No_ROOM:
		_get_list_of_rooms()
	else:
		print("trying to login")
		_login()
		print("Creating room ")
		_on_create_room()
func _connect():
	_client.connect_to_host(HOST, PORT)
	
func _on_join_room_pressed(UID: String):
	if !_client.is_online():
		return
		
	# Serveriui duodamas room UID prie kurio prisijungti
	_client.send("1;%s" % UID)
	await _client.response
	print("Game start response: ", lastData)
	if lastData[0] == "0":
		print("GAME STARTED")
		game_state = GameState.AWAIT_ATTACK
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func handle_game_response():
	match game_state:
		GameState.ATTACK:
			# Jei tai nera success packetas, ivyko kazkas blogai, arba ne jo
			# ejimas
			if lastData[0] != "0":
				return
			game_state = GameState.AWAIT_RESPONSE
		GameState.RESPOND:
			# Jei tai nera success packetas, ivyko kazkas blogai
			if lastData[0] != "0":
				return
			game_state = GameState.ATTACK
		GameState.AWAIT_ATTACK:

			if lastData[0] != "2":
				# Serveris visada turetu grazinti kokia informacija,
				# todel jei negrazina ivyko kazkas blogai
				return
			if lastData[1] != "0":
				# Serveris siuo metu turetu grazint 0 game
				# response, kadangi tai yra gautos atakos koordinates
				return
			# Gaunam oponento suvio koordinates is response
			var x = int(lastData[2])
			var y = int(lastData[3])
			print("Oponentas sove X: %s, Y: %s" % [x, y])
			# Cia turetu buti apskaiciuojama ar suvis pataike ir siunciamas
			# response ar pataike ar ne
			game_state = GameState.RESPOND
		GameState.AWAIT_RESPONSE:
			if lastData[0] != "2":
				# Serveris visada turetu grazinti kokia informacija,
				# todel jei negrazina ivyko kazkas blogai
				return
			if lastData[1] != "1":
				# Serveris siuo metu turetu grazint 1 game
				# response, kadangi tai yra move response data
				return
			# Response values: 0 - not hit; 1 - hit; 2 - game end
			# jei 2, uzbaigti zaidima ir zaidejes gaves si response laimejo
			match lastData[2]:
				"0":
					print("Sent shot didn't hit")
					game_state = GameState.AWAIT_ATTACK
				"1":
					print("Sent shot hit")
					game_state = GameState.AWAIT_ATTACK
				"2":
					print("Sent shot hit and you win")
					game_state = GameState.WINNER
					_client.disconnect_from_host()
		_:
			# Zaidimas arba neprasidejes arba baigesi
			print("Server error, but got game response from server")


func _on_cancel_pressed():
	True_exit=true
	_client.disconnect_from_host()
	get_tree().change_scene_to_file("res://menus/menu.tscn")
