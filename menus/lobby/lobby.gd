extends Node2D

var SearchName=""
var PlayerName="Shrek"
const HOST: String = "localhost"
const PORT: int = 24845
var Status


@onready
var _client = get_node("/root/TCPClient")
var lastData: PackedStringArray

@onready
var lobbyContainer = $VBoxContainer
# Refresh Connect -> Status -> disconnected -> connect

# Login) Connect -> login => create room 

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
		Status=3
		#  Trinti turini is VBoxContainer
		for child in lobbyContainer.get_children():
			lobbyContainer.remove_child(child)
			
		#  Prideti turini i VBoxContainer
		for n in range(players.size()):
			print(SearchName +" name of player")
			if (SearchName == "" || players[n] == SearchName):
				var playerLabel = Label.new()
				playerLabel.text = players[n]
				#playerLabel.align = Label.PRESET_CENTER 
				lobbyContainer.add_child(playerLabel)
				var joinButton = Button.new()
				joinButton.text = "Join"
				
				
 # Create a StyleBoxFlat for the rounded button appearance
				var buttonStyle = StyleBoxFlat.new()
				buttonStyle.set_border_width_all(2)
				#buttonStyle.border_width = 2  # Adjust border width as needed
				buttonStyle.border_color = Color(1, 0, 0)  # Border color
				buttonStyle.set_corner_radius_all(40)
				#buttonStyle.border_radius = 10  # Adjust radius to make it rounde
				
				joinButton.theme = buttonStyle
			
		# Set the custom background style for the button
		
				joinButton.connect("pressed", _join_match.bind(rooms[n]))
				lobbyContainer.add_child(joinButton)
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





func _on_texture_button_pressed():
	# Atliekamas Connect -> Status
	#if _client.is_online():
	#	_client.disconnect_from_host()
	Status=0
	_connect()


func _on_line_edit_text_changed(new_text):
	SearchName=new_text


func _on_back_pressed():

	get_tree().change_scene_to_file("res://menus/menu.tscn")
