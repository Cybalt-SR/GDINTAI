extends Node

var universalTeamNames: Array[String]=[
"GREEN",
"RED",
"AQUA",
"BLUE"
]
var playerDict := {
universalTeamNames[0]: "PLAYER"
}
var unitList:Array[int] = [0];
var universalColorCode :={
universalTeamNames[0]: Color.GREEN,
universalTeamNames[1]: Color.RED * 2,
universalTeamNames[2]: Color.AQUAMARINE * 0.7,
universalTeamNames[3]: Color.BLUE * 1,
}
var baseCount:int;
var mapChoice:PackedScene;
