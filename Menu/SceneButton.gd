extends Button

@export var sceneTo:String;

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_onPress)
	pass # Replace with function body.

func _onPress():
		await get_tree().change_scene_to_file(sceneTo);
