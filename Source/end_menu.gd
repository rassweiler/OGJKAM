extends Control

onready var globals = get_node('/root/globals')

func _ready():
	if globals.game_state.winner != null:
		if globals.game_state.winner == 1:
			get_node("EndMenuBackground/TeamNameRR").set("visibility/visible", false)
			get_node("EndMenuBackground/TeamNameMJP").set("visibility/visible", true)
		elif globals.game_state.winner == 0:
			get_node("EndMenuBackground/TeamNameRR").set("visibility/visible", true)
			get_node("EndMenuBackground/TeamNameMJP").set("visibility/visible", false)

	set_process_input(true)

func _input(event):
	if event.type == InputEvent.JOYSTICK_BUTTON and event.button_index == JOY_XBOX_Y:
		globals.goto_scene("res://menu.tscn")
	