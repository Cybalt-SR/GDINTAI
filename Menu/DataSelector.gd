extends MenuButton
class_name Data_Selector

@export var label:String;
@export var value:int;

# Called when the node enters the scene tree for the first time.
func _ready():
	get_popup().id_pressed.connect(_onSelect);
	_onSelect(value);
	pass # Replace with function body.

func _onSelect(id:int):
	value = id;
	text = label + " : " + get_popup().get_item_text(id);
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
