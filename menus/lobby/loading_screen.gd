extends Control
var rooms
#var players
@onready var PlayerName = get_node("/root/Data").NAME
#const HOST: String = "localhost"
#const PORT: int = 24845
#var HOST
#var PORT
var Status

@onready var HOST = get_node("/root/Data").HOST
@onready var PORT = get_node("/root/Data").PORT
@onready var _client = get_node("/root/TCPClient")
var lastData: PackedStringArray

@onready
var lobbyContainer = $VBoxContainer
# Refresh Connect -> Status -> disconnected -> connect

# Login) Connect -> login => create room 

func _ready():
	
	print(HOST)
	print(PORT)

	_client.connected.connect(_handle_client_connected)
	_client.disconnected.connect(_handle_client_disconnected)
	_client.errored.connect(_handle_client_error)
	_client.response.connect(_handle_client_data)
	_initial_start()
	



func _handle_client_error(error: int) -> void:
	print("Client error.")

func _connect() -> void:
	_client.connect_to_host(HOST, PORT)

func _login():
	if !_client.is_online():
		return
		
	_client.send("0;%d;1" % _client.PROTOCOL_VERSION)
	await _client.response
	print("Handshake response: ", lastData)
	# Testing
	#var random_number = randi() % 101
	#_client.send("0;"+PlayerName+""+str(random_number))
	_client.send("0;"+PlayerName)
	await _client.response
	print("Login response: ", lastData)

func _status():
	print(" _status()")
	if !_client.is_online():
		return
		
	_client.send("0;%d;0" % _client.PROTOCOL_VERSION)
	await _client.response
	print("Handshake response: ", lastData)
	_client.send("0")
	await _client.response
	
	if (lastData.size() > 2):
		rooms= lastData[1].split(",")[0]
		#players=lastData[2].split(",")[0]
		
		Status=3

		
	else:
	# Atliekamas Connect -> Login -> Join
		Status=2


func _join_match(UID):
	await _login()
	
	print("Joining room:", UID)
	_client.send("1;%s" % UID)
	await _client.response
	print("Game start response: ", lastData)
	if lastData[0] == "0":
		print("GAME STARTED")
		_client.game_state = _client.GameState.AWAIT_ATTACK
		get_tree().change_scene_to_file("res://board/pre_battle.tscn")

func _handle_client_data(data: Array) -> void:
	lastData = data

	
func _handle_client_connected() -> void:
	print("Client connected to server.")
	if (Status == 0):
		_status()
	elif (Status == 2):
		print("room creation")
		await _login()
		_create_room()
	elif (Status == 3):
		_join_match(rooms)



func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")
	# Kai noriu paziureti sarasa atjungia mane
	if (Status == 2 || Status==3):
		await _connect()


func _process(delta):
	pass

func _create_room():
	if !_client.is_online():
		return
	_client.send("0")
	await _client.response
	print("Room created: ", lastData)
	await _client.response
	print("Opponent connected: ", lastData)
	if lastData[0] == "0":
		print("GAME STARTED")
		_client.game_state = _client.GameState.ATTACK
		get_tree().change_scene_to_file("res://board/pre_battle.tscn")





func _initial_start():
	Status=0
	_connect()



func _on_cancel_pressed():
	get_tree().change_scene_to_file("res://menus/menu.tscn")
