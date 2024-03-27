extends Control

@export var gameBoard:GameBoard;
@export var gameLoader:GameLoader;

@export var infoLabel:Label;
@export var winnerLabel:Label;
@export var scoreLabel:Label;

func _ready():
	gameBoard._onWin.connect(_onWin);
	pass
	
func _onWin(teamName:String):
	winnerLabel.visible = true;
	
	if(teamName.length() > 0):
		winnerLabel.text = "WINNER:" + teamName;
	else:
		winnerLabel.text = "DRAW";
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(gameLoader.loadedin == false):
		return;
		
	infoLabel.text = "";
	
	infoLabel.text = "Current Turn : " + gameBoard._get_current_team_turn();
	infoLabel.text += "\n";
	infoLabel.text += "Turn time left : " + str(gameBoard._turn_maxtime - gameBoard._turn_timer).substr(0, 3);
	infoLabel.text += "\n";
	infoLabel.text += "Game time left : " + str(gameBoard._game_maxtime - gameBoard._game_timer).substr(0, 5);
	
	scoreLabel.text = "";
	for teamName in gameBoard._teamscore:
		scoreLabel.text += teamName + ": " + str(gameBoard._teamscore[teamName]) + "\n";
	
	pass
