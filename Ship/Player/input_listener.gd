extends Node2D
class_name GDInputListener

@export var input_direction:Vector2;
@export var aim_direction:Vector2;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	input_direction = Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down");
	aim_direction = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down");
	pass
