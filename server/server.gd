extends Node

signal connected
signal response(Array)
signal disconnected
signal errored(int)

enum State {HANDSHAKING, STATUS, LOGIN, MATCHMAKING, PLAY}
enum SError {UNKNOWN, INTERNAL, CONNECTION, INVALID_PACKET, INVALID_FIELD, VERSION_MISMATCH, INVALID_UUID, INVALID_ROOM, WAITING_FOR_OPPONENT}
enum DataType {INTEGER, STRING, BOOLEAN, ENUM, ARRAY_INT, ARRAY_STRING}
enum Response {SUCCESS, ERROR, DATA}

const PROTOCOL_VERSION = 0;
var _status: StreamPeerTCP.Status = StreamPeerTCP.Status.STATUS_NONE
var _stream: StreamPeerTCP = StreamPeerTCP.new()

func _ready() -> void:
	_status = _stream.get_status()

func _process(_delta: float) -> void:
	_stream.poll()
	var new_status: StreamPeerTCP.Status = _stream.get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			_stream.STATUS_NONE:
				disconnected.emit()
			_stream.STATUS_CONNECTING:
				tprint("Connecting...")
			_stream.STATUS_CONNECTED:
				connected.emit()
			_stream.STATUS_ERROR:
				errored.emit(SError.CONNECTION)

	if _status == _stream.STATUS_CONNECTED:
		var available_bytes: int = _stream.get_available_bytes()
		if available_bytes > 0:
			var buffer = _stream.get_partial_data(available_bytes)
			var byte_buffer = PackedByteArray(buffer[1])
			var data = parse_response(byte_buffer.get_string_from_utf8())
			response.emit(data)
				
func is_online() -> bool:
	return _status == _stream.STATUS_CONNECTED
	
func parse_response(data: String) -> PackedStringArray:
	var splitData = Array(data.split(";", false))
	if splitData.size() == 0 || splitData[0] == "1":
		errored.emit(splitData[1] if splitData.size() > 1 else SError.UNKNOWN)
	return splitData.map(func(field: String): return field.rstrip(" \n\t").lstrip(" \n\t"));

func connect_to_host(host: String, port: int) -> void:
	tprint("Connecting to %s:%d" % [host, port])
	# Reset status so we can tell if it changes to error again.
	_status = _stream.STATUS_NONE
	if _stream.connect_to_host(host, port) != OK:
		tprint("Error connecting to host.")
		errored.emit(SError.CONNECTION)

func disconnect_from_host() -> void:
	tprint("Disconnecting from TCP server")
	_stream.disconnect_from_host()

func send(data: String) -> bool:
	if _status != _stream.STATUS_CONNECTED:
		tprint("Error: Stream is not currently connected.")
		return false
	var error = _stream.put_data(data.to_utf8_buffer())
	if error != OK:
		tprint("Error writing to stream: " + error)
		return false
	return true
	
func tprint(msg: String) -> void:
	print("[TCP] ", msg)
