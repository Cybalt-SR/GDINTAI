extends Unit

func _on_stepover(by:Unit):
	gameBoard._killUnit(by);
	gameBoard._killUnit(self);
	by._path_follow.progress_ratio = 1;
	pass # Replace with function body.
