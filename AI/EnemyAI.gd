extends Node
class_name UnitAI

@export var teamName:String
@export var gameBoard:GameBoard;

var pathfinder:PathFinder:
	get:
		return gameBoard._unit_path._pathfinder;

func _get_path_length(start: Vector2, end: Vector2) -> float:
	return pathfinder.calculate_point_path(start, end).size();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(gameBoard._get_current_team_turn() == teamName):
		var priorityDictionary := {}
		#variable finding
		var aiTeam:Array[Unit];
		var aiBases:Array[Unit];
		aiTeam.assign(gameBoard._teams[teamName]);
		for aiUnit in aiTeam:
			if(aiUnit.move_range == 0):
				aiBases.append(aiUnit);
		
		for targetTeamName in gameBoard._teams:
			if(targetTeamName == teamName):
				continue;
			var isneutralteam := true;
			
			var targetTeam = gameBoard._teams[targetTeamName];
			var targetBases:Array[Unit];
			for target in targetTeam:
				if(target.move_range == 0):
					targetBases.append(target);
			
			#target aquisition
			#defence priority check
			for target in targetTeam:
				if(target.move_range > 0):
					isneutralteam = false;
					var distToNearestBase := 1000.0;
					for	aiBase in aiBases:
						var curDist := _get_path_length(target.cell, aiBase.cell);
						if(curDist < distToNearestBase):
							distToNearestBase = curDist;
					priorityDictionary[target.cell] = 150.0 / distToNearestBase / aiBases.size();
			#attack priority check
			for targetBase in targetBases:
				var distToNearestPlayer := 1000.0;
				for	target in targetTeam:
					if(target.move_range > 0):
						var curDist := _get_path_length(targetBase.cell, target.cell);
						if(curDist < distToNearestPlayer):
							distToNearestPlayer = curDist;
				if(!isneutralteam):
					priorityDictionary[targetBase.cell] = 100.0 / distToNearestPlayer / (targetBases.size() * 0.5);
				else:
					priorityDictionary[targetBase.cell] = 10.0 / distToNearestPlayer * targetBase.targetPriorityMod;
				
		#weight priority by distance
		for key in priorityDictionary:
			var distanceToHere := 1000.0;
			for aiUnit in aiTeam:
				if(aiUnit.move_range > 0):
					var curDist := _get_path_length(aiUnit.cell, key);
					if(curDist < distanceToHere):
						distanceToHere = curDist;
			priorityDictionary[key] *= minf(1.0, 10.0 / distanceToHere);
		
		#prune all positions in which there is no need to move
		for key in priorityDictionary:
			for aiUnit in aiTeam:
				if(aiUnit.move_range > 0 && aiUnit.cell == key):
					priorityDictionary[key] = -1;
		
		#pick priotity
		var mostPrioritizedPosition:Vector2;
		var highestPriority := 0;
		
		for key in priorityDictionary:
			var thisPrio:float = priorityDictionary[key];
			if(thisPrio > highestPriority && !gameBoard.is_occupied(key)):
				mostPrioritizedPosition = key;
				highestPriority = thisPrio;
				
		#select nearest unit to prioed position
		var selectedUnit:Unit = null;
		var distanceToHere := 1000.0;
		for aiUnit in aiTeam:
			if(aiUnit.move_range > 0):
				var curDist := _get_path_length(aiUnit.cell, mostPrioritizedPosition);
				if(curDist < distanceToHere || selectedUnit == null):
					selectedUnit = aiUnit;
					distanceToHere = curDist;
		
		#action
		if(selectedUnit == null):
			return;
		
		gameBoard._on_Cursor_accept_pressed(selectedUnit.cell);
		
		gameBoard._on_Cursor_moved(mostPrioritizedPosition);
		gameBoard._on_Cursor_accept_pressed(mostPrioritizedPosition);
		pass;
	pass
