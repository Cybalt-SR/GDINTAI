extends Unit

func _on_stepover(by:Unit):
	for base:Unit in by.bases:
		if(is_instance_valid(base)):
			base._timeInvulnerable = 10;
	pass # Replace with function body.
