extends Control

@export var gameBoard:GameBoard;
@export var gameLoader:GameLoader;

@export var infoLabel:Label;
@export var winnerLabel:Label;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(gameLoader.loadedin == false):
		return;
		
	var newText:String = "";
	
	newText = "Current Turn : " + gameBoard._get_current_team_turn() + "\n";
	newText = newText + "Turn time left : " + str(gameBoard._turn_maxtime - gameBoard._turn_timer).substr(0, 3);
	
	infoLabel.text = newText;
	
	var teamsAlive := 0;
	
	for teamname in gameBoard._teams:
		if(teamname != "spawn"):
			
			winnerLabel.visible = true;
			winnerLabel.text = "WINNER:" + teamname;
	pass
