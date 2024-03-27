extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_quit);
	pass # Replace with function body.
	
func _quit():
	get_tree().quit();
