extends Control

onready var globals = get_node("/root/globals")

var slots = {
	0: null,
	1: null,
	2: null,
	3: null
}

var slot_info = [{
	"index": 0,
	"team": 0,
	"position": 0,
	"holder": "Positions/Team01/TruckSnap"
}, {
	"index": 1,
	"team": 0,
	"position": 1,
	"holder": "Positions/Team01/SwingerSnap"
}, {
	"index": 2,
	"team": 1,
	"position": 0,
	"holder": "Positions/Team02/TruckSnap"
}, {
	"index": 3,
	"team": 1,
	"position": 1,
	"holder": "Positions/Team02/SwingerSnap"
}]

var player_els = [{
	"join": "Players/Player01/JoinIndicator",
	"token": "Players/Player01/Player001",
	"tokenInitial": Vector2()
}, {
	"join": "Players/Player02/JoinIndicator",
	"token": "Players/Player02/Player002",
	"tokenInitial": Vector2()
}, {
	"join": "Players/Player03/JoinIndicator",
	"token": "Players/Player03/Player003",
	"tokenInitial": Vector2()
}, {
	"join": "Players/Player04/JoinIndicator",
	"token": "Players/Player04/Player004",
	"tokenInitial": Vector2()
}]

func _ready():
	for i in range(4):
		player_els[i]["tokenInitial"] = get_node(player_els[i]["token"]).get_pos()
	
	set_process_input(true)
	
func nextOpenSlot():
	for s in range(4):
		if slots[s] == null:
			return slot_info[s]
	
	return null

func clearSlot(slot):
	slots[slot] = null
	
func removePlayer(player):
	for s in range(4):
		if slots[s] == player:
			clearSlot(s)
			
	get_node(player_els[player.index]["join"]).set("visibility/visible", true)
	get_node(player_els[player.index]["token"]).set_pos(player_els[player.index]["tokenInitial"])
			
func playerInSlot(player):
	for s in range(4):
		if slots[s] == player:
			return true
	return false
	
func slotPlayer(player, intoSlot):
	get_node(player_els[player.index]["join"]).set("visibility/visible", false)
	get_node(player_els[player.index]["token"]).set_pos(get_node(intoSlot["holder"]).get_global_pos() - get_node(player_els[player.index]["token"]).get_parent().get_pos())
	
	var joined_players = 0
	for i in range(4):
		if slots[i] != null:
			joined_players += 1
	
	if joined_players > 1:
		pass #SHOW PRESS START TO START GAME BUTTON
	
func _input(event):
	var player = globals.getFromDevice(event.device)
	
	if player == null: #we know they are not in slot yet
		if event.type == InputEvent.JOYSTICK_BUTTON and event.button_index == JOY_XBOX_A:
			var intoSlot = nextOpenSlot()
			
			if intoSlot != null: #still room
				player = globals.addPlayer(event.device, intoSlot["team"], intoSlot["position"])
				slots[intoSlot["index"]] = player
				slotPlayer(player, intoSlot)
				return
	
	#They already registered their device they just need to be teamed
	if not playerInSlot(player):
		if event.type == InputEvent.JOYSTICK_BUTTON and event.button_index == JOY_XBOX_A:
			var intoSlot = nextOpenSlot()
			slots[intoSlot["index"]] = player
			slotPlayer(player, intoSlot)
			return
			
	if event.type == InputEvent.JOYSTICK_BUTTON and player:
		if event.button_index == JOY_XBOX_B and playerInSlot(player):
			removePlayer(player)

#