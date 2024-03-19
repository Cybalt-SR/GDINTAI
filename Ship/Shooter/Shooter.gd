extends Node2D
class_name GDShooter;

@export var Bullet:PackedScene;
@export var maxRate:float;

var timeSinceLastShot:float;

func Shoot(shootDirection:Vector2, initialDistance:float):
	if(timeSinceLastShot < 1 / maxRate):
		return;
	
	var b = Bullet.instantiate()
	b.transform = global_transform;
	b.position += shootDirection * initialDistance;
	b.rotation = shootDirection.angle();
	get_tree().current_scene.add_child(b)
	timeSinceLastShot = 0;
	pass;

func _process(delta):
	timeSinceLastShot += delta;
	pass;
