extends Node

var team_state = {
	0: {
		"score": 0
	},
	1: {
		"score": 0
	}
}

var num_poles = 20

var winner = null

func set_pole_count(count):
	num_poles = count - 1 #1 pole is always had but not scored for

func reset_game():
	for i in range(2):
		team_state[i]["score"] = 0

func team_scored(team):
	team_state[team]["score"] += 1
	
	check_game_state()

func check_game_state():
	print (team_state[0]["score"], "=>", num_poles)
	print (team_state[1]["score"], "=>", num_poles)
	if team_state[0]["score"] == num_poles:
		winner = 0
	elif team_state[1]["score"] == num_poles:
		winner = 1

func _ready():
	pass
