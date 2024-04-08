extends RichTextLabel
# TODO: Reset time and change player's turn after missing to hit a ship

var YOUR_TURN_TEXT := "[color=blue][center]\nYOUR TURN[/center]" 
var OPPONENTS_TURN_TEXT := "[color=blue][center]\nOPPONENT'S TURN[/center]" 

var is_your_turn := false;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_timer_timeout():
	var Turn = get_node(".")
	if (Turn == null):
		return

	if (is_your_turn):
		Turn.text = YOUR_TURN_TEXT
		is_your_turn = false
		return
		
	Turn.text = OPPONENTS_TURN_TEXT
	is_your_turn = true
	

