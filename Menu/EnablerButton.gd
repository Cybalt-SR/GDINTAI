extends Button

@export var toEnable:Array[Node];
@export var toDisable:Array[Node];

# Called when the node enters the scene tree for the first time.
func _ready():
	button_down.connect(_onpress);
	pass # Replace with function body.

func _onpress():
	for node:Node in toEnable:
		node.visible = true;
	for node:Node in toDisable:
		node.visible = false;
	pass;
