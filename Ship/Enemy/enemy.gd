extends ObjectBody

@export var navigationAgent:NavigationAgent2D;
@export var target:Node2D;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	navigationAgent.set_target_position(target.global_position);
	var nextPoint = navigationAgent.get_next_path_position();
	movementVector = global_position.direction_to(nextPoint);
	print(navigationAgent.is_target_reachable())
	
	pass
