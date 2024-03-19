extends ObjectBody

@export var mInputListener:GDInputListener;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	movementVector = mInputListener.input_direction;
	
	pass
