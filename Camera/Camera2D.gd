extends Camera2D

@export var follow:Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = follow.position;
	pass
