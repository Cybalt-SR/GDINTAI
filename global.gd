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
universalTeamNames[1]: Color.RED * 3,
universalTeamNames[2]: Color.AQUAMARINE * 2,
universalTeamNames[3]: Color.BLUE * 2,
}
var baseCount:int;
