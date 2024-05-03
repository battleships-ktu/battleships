extends Node2D

var SearchName=""
var PlayerName="Shrek"
const HOST: String = "localhost"
const PORT: int = 24845
var Status

enum GameState {NOT_STARTED, ATTACK, AWAIT_ATTACK, AWAIT_RESPONSE, RESPOND, WINNER, LOSER}

@onready
var _client = get_node("/root/TCPClient")
var lastData: PackedStringArray
var game_state = GameState.NOT_STARTED
@onready
var lobbyContainer = $VBoxContainer

func _ready():
	_client.connected.connect(_handle_client_connected)
	_client.disconnected.connect(_handle_client_disconnected)
	_client.errored.connect(_handle_client_error)
	_client.response.connect(_handle_client_data)
	



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
		var rooms= lastData[1].split(",")
		var players=lastData[2].split(",")
		print("Empty rooms: ",rooms)
		print("Players: ", players)

		#  Trinti turini is VBoxContainer
		for child in lobbyContainer.get_children():
			lobbyContainer.remove_child(child)
			
		#  Prideti turini i VBoxContainer
		for n in range(players.size()):
			print(SearchName +" name of player")
			if (SearchName == "" || players[n] == SearchName):
				var playerLabel = Label.new()
				playerLabel.text = players[n]
				lobbyContainer.add_child(playerLabel)
				var joinButton = Button.new()
				joinButton.text = "Join"
				joinButton.connect("pressed", _join_match.bind(rooms[n]))
				lobbyContainer.add_child(joinButton)
	
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
		#game_state = GameState.AWAIT_ATTACK
		get_tree().change_scene_to_file("res://board/pre_battle.tscn")

func _handle_client_data(data: Array) -> void:
	lastData = data
	if (game_state != GameState.NOT_STARTED):
		handle_game_response()
	
func _handle_client_connected() -> void:
	print("Client connected to server.")
	if (Status == 0):
		_status()
	elif (Status == 1):
		print("room creation")
		await _login()
		_create_room()



func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")
	# Kai noriu paziureti sarasa atjungia mane
	if (Status == 2):
		await _connect()

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
# Called every frame. 'delta' is the elapsed time since the previous frame.
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
		get_tree().change_scene_to_file("res://board/pre_battle.tscn")
		game_state = GameState.ATTACK


func _on_button_pressed():
	# Atliekamas Connect -> Login -> Create room
	Status=1
	_connect()




func _on_texture_button_pressed():
	# Atliekamas Connect -> Status
	Status=0
	_connect()


func _on_line_edit_text_changed(new_text):
	SearchName=new_text
