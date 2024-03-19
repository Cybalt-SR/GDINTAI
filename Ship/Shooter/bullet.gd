extends RigidBody2D

func _ready():
	linear_velocity = 1000 * Vector2.RIGHT.rotated(transform.get_rotation());
	pass;

func _on_body_entered(body):
	if(body is ObjectBody):
		body.GetHit();
		
	queue_free();
	pass # Replace with function body.
