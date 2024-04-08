extends RichTextLabel

@onready var timer = get_node("Timer")
@onready var time_node = get_node(".")

# Called when the node enters the scene tree for the first time.
func _ready():
	if (timer == null):
		print("Timer is not found")
		return
	
	timer.start()

func time_left_to_live():
	if (timer == null || timer.time_left == null):
		print("Timer is not found")
		return null
		
	var time_left = timer.time_left
	var second = int(time_left) % 60
	
	return second
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (time_node == null || time_node.text == null):
		print("Time node is not found")
		return
		
	var time_left_to_live = time_left_to_live();
	if (time_left_to_live == null):
		print("time_left_to_live failed")
		return
		
	time_node.text = "[color=blue][center]\n%02d[/center]" % time_left_to_live

func _on_timer_timeout():
	pass # Replace with function body.
