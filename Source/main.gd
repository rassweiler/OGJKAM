extends Node2D

onready var globals = get_node('/root/globals')

var start_pressed = false

onready var delay = OS.get_ticks_msec()

func _ready():
	set_process_input(true)

func _input(event):
	if OS.get_ticks_msec() - delay < 1000: #if releasing from start menu dont pause here
		return
		
	if get_tree().is_paused():
		if event.type == InputEvent.JOYSTICK_BUTTON and event.button_index == JOY_START:	
			get_parent().get_node("Camera/PauseMenu").set("visibility/visible", false)
			get_tree().set_pause(false)
			delay = OS.get_ticks_msec()
	else:
		if event.type == InputEvent.JOYSTICK_BUTTON and event.button_index == JOY_START:
			get_parent().get_node("Camera/PauseMenu").set("visibility/visible", true)
			get_tree().set_pause(true)
			delay = OS.get_ticks_msec()
			
	if get_tree().is_paused():
		if event.type == InputEvent.JOYSTICK_BUTTON and event.button_index == JOY_XBOX_A: #QUIT
			get_tree().set_pause(false)
			get_parent().get_node("Camera/PauseMenu").set("visibility/visible", false)
			globals.goto_scene("res://menu.tscn")
