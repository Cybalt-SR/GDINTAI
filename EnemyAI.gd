extends Node
@export var teamName:String
@export var targetTeamName:String
@export var gameBoard:GameBoard;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(gameBoard._teams[gameBoard._cur_turn][0].teamName == teamName):
		#variable finding
		var targetTeam:Array[Unit]; 
		var aiTeam:Array[Unit];
		for	team in gameBoard._teams:
			if(team[0].teamName == teamName):
				aiTeam.assign(team);
			if(team[0].teamName == targetTeamName):
				targetTeam.assign(team);
		
		var targetBases:Array[Unit];
		var aiBases:Array[Unit];
		
		for target in targetTeam:
			if(target.move_range == 0):
				targetBases.append(target);
		for aiUnit in aiTeam:
			if(aiUnit.move_range == 0):
				aiBases.append(aiUnit);
		
		#target aquisition
		var priorityDictionary := {}
		#defence priority check
		for target in targetTeam:
			if(target.move_range > 0):
				var distToNearestBase := 1000.0;
				for	aiBase in aiBases:
					var curDist := target.cell.distance_squared_to(aiBase.cell);
					if(curDist < distToNearestBase):
						distToNearestBase = curDist;
				priorityDictionary[target.cell] = 100.0 / distToNearestBase / aiBases.size();
		#attack priority check
		for targetBase in targetBases:
			var distToNearestPlayer := 1000.0;
			for	target in targetTeam:
				if(target.move_range > 0):
					var curDist := targetBase.cell.distance_squared_to(target.cell);
					if(curDist < distToNearestPlayer):
						distToNearestPlayer = curDist;
			priorityDictionary[targetBase.cell] = 100.0 / distToNearestPlayer / targetBases.size();
		
		#weight priority by distance
		for key in priorityDictionary:
			var distanceToHere := 1000.0;
			for aiUnit in aiTeam:
				if(aiUnit.move_range > 0):
					var curDist := aiUnit.cell.distance_squared_to(key);
					if(curDist < distanceToHere):
						distanceToHere = curDist;
			priorityDictionary[key] += 200.0 / distanceToHere;
			
		var mostPrioritizedPosition:Vector2;
		var highestPriority := 0;
		
		for key in priorityDictionary:
			var thisPrio:float = priorityDictionary[key];
			if(thisPrio > highestPriority):
				mostPrioritizedPosition = key;
				highestPriority = thisPrio;
				
		#select nearest unit to prioed position
		var selectedUnit:Unit = null;
		var distanceToHere := 1000.0;
		for aiUnit in aiTeam:
			if(aiUnit.move_range > 0):
				var curDist := aiUnit.cell.distance_squared_to(mostPrioritizedPosition);
				if(curDist < distanceToHere || selectedUnit == null):
					selectedUnit = aiUnit;
					distanceToHere = curDist;
		#action
		gameBoard._on_Cursor_accept_pressed(selectedUnit.cell);
		
		var nearestWalkableCell;
		var nearestDist = 1000.0;
		for	walkableCell in gameBoard._walkable_cells:
			var curDist := walkableCell.distance_squared_to(mostPrioritizedPosition);
			if(curDist < nearestDist):
				nearestDist = curDist;
				nearestWalkableCell = walkableCell;
		
		gameBoard._on_Cursor_moved(nearestWalkableCell);
		gameBoard._on_Cursor_accept_pressed(nearestWalkableCell);
		pass;
	pass
