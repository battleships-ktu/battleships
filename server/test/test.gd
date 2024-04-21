extends Node2D

const HOST: String = "localhost"
const PORT: int = 24845

enum GameState {NOT_STARTED, ATTACK, AWAIT_ATTACK, AWAIT_RESPONSE, RESPOND, WINNER, LOSER}

@onready
var _client = $Client
var lastData: PackedStringArray
var game_state = GameState.NOT_STARTED

# Hackas kad rodyti game state pasikeitimus gui, NENAUDOTI PRODE!!!
var last_game_state = GameState.NOT_STARTED

func _ready() -> void:
	_client.connected.connect(_handle_client_connected)
	_client.disconnected.connect(_handle_client_disconnected)
	_client.errored.connect(_handle_client_error)
	_client.response.connect(_handle_client_data)
	
func _process(_delta):
	# HACKAS PAKEISTI LABEL TEXTA NENAUDOTI KAI DARYSIT NORMALIAI
	if last_game_state == game_state:
		return
		
	var text = ""
	last_game_state = game_state
	match game_state:
		GameState.NOT_STARTED:
			text = "Not started NOT_STARTED"
		GameState.ATTACK:
			text = "Attack ATTACK"
		GameState.AWAIT_ATTACK:
			text = "Waiting for an attack from opponent AWAIT_ATTACK"
		GameState.AWAIT_RESPONSE:
			text = "Waiting for a response from opponent AWAIT_RESPONSE"
		GameState.RESPOND:
			text = "Respond to opponent whether shot hit RESPOND"
		GameState.WINNER:
			text = "You won WINNER"
		GameState.LOSER:
			text = "You lost LOSER"
		_:
			text = "ERROR"
			
	$Game_state_label.text = text

# Response listeneriai is TCP client connectiono
func _handle_client_connected() -> void:
	print("Client connected to server.")

func _handle_client_data(data: Array) -> void:
	lastData = data
	if (game_state != GameState.NOT_STARTED):
		handle_game_response()

func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")

func _handle_client_error(error: int) -> void:
	print("Client error.")


func _on_connect_pressed():
	_client.connect_to_host(HOST, PORT)


func _on_disconnect_pressed():
	_client.disconnect_from_host()

# Sitas kodas turi buti paleistas keikviena karta jei norim sukurti kambari 
# arba prisijungti prie kambario (aisku nereik print ir varda ivesti savo)
# serveris gali grazint errorus bet dabar del to nesinervuojam ir net nechekinam
func _on_login_pressed():
	if !_client.is_online():
		return
		
	_client.send("0;%d;1" % _client.PROTOCOL_VERSION)
	await _client.response
	print("Handshake response: ", lastData)
	_client.send("0;Test name")
	await _client.response
	print("Login response: ", lastData)
	
# Sitas kodas turi buti paleistas jei norim gauti sarasa useriu kurie sukure
# kambari ir iesko priesininko
func _on_status_pressed():
	if !_client.is_online():
		return
		
	_client.send("0;%d;0" % _client.PROTOCOL_VERSION)
	await _client.response
	print("Handshake response: ", lastData)
	_client.send("0")
	await _client.response
	print("Empty rooms: ", lastData)

# Sukurti kambari. Pirmas reponse confirmationas, kad kambarys sukurtas,
# antras response, kad rastas oponentas ir zaidimas prasidejo
func _on_create_room_pressed():
	if !_client.is_online():
		return
		
	_client.send("0")
	await _client.response
	print("Room created: ", lastData)
	await _client.response
	print("Opponent connected: ", lastData)
	if lastData[0] == "0":
		print("GAME STARTED")
		game_state = GameState.ATTACK

# Prisijungti prie kambario, jei grazina 0, zaidimas prasidejo, jei ne, ivestas
# blogas kambario UID
func _on_join_room_pressed():
	if !_client.is_online():
		return
		
	# Serveriui duodamas room UID prie kurio prisijungti
	_client.send("1;%s" % $Room_edit.get_line(0))
	await _client.response
	print("Game start response: ", lastData)
	if lastData[0] == "0":
		print("GAME STARTED")
		game_state = GameState.AWAIT_ATTACK
	
# ZAIDIMAS PRASIDEJO, visos kitas kodas turetu buti siunciamas tik kai zaidimas
# prasidejes

# Siusti kur issauni priesininkui
func _on_strike_pressed():
	if !_client.is_online():
		return
	if (game_state != GameState.ATTACK):
		# Tai galima siusti tik, kai turi siunti bomba
		return
		
	# Siusti koordinates kur saunama, pirmas response success, antras
	# grazinamas kai gaunamas response is oponento ar pataike
	_client.send("0;%s;%s" % [$x_edit.get_line(0), $y_edit.get_line(0)])

func _on_shot_response_pressed():
	if !_client.is_online():
		return
	if (game_state != GameState.RESPOND):
		# Tai galima siusti tik, kai zaidejas turi atsakyti ar oponentas pataike
		return
		
	# Grazinti oponentui ar sovinys pataike, dabar visada grazinima 1 (TRUE),
	# bet pakeitus antra skaiciu galima grazinti ka nori, svarbu butu boolean
	_client.send("1;1")

func _on_end_game_pressed():
	if !_client.is_online():
		return
	if (game_state != GameState.RESPOND):
		# Tai galima siusti tik, kai zaidejas turi atsakyti ar oponentas pataike
		return
		
	# Vietoj to, kad siusti pataike ar nepataike, siunciama, kad zaidimas
	# jei zaidejas turi issiusti tai, reiskias pralaimejo
	_client.send("2")
	game_state = GameState.LOSER

# Visos kodas handlinti skirtingus serverio responses game metu
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
