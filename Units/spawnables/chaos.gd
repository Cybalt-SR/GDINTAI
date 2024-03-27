extends Unit

func _on_stepover(by:Unit):
	for teamName in gameBoard._teams:
		if(teamName == "spawn"):
			continue;
		
		for unit:Unit in gameBoard._teams[teamName]:
			if(unit.move_range == 0):
				var spawnPos:Vector2 = gameBoard._get_empty();
				unit.cell = spawnPos;
				unit.position = grid.calculate_map_position(unit.cell);
	
	gameBoard._killUnit(self);
	pass # Replace with function body.
