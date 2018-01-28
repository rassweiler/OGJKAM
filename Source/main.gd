extends Node2D

onready var globals = get_node('/root/globals')

var start_pressed = false

onready var delay = OS.get_ticks_msec()

func _ready():
	set_process_input(true)

func _input(event):
	if OS.get_ticks_msec() - delay < 1000: #if releasing from start menu dont pause here
		return
	
	var just_pressed = false
	var just_released = false
	if event.type == InputEvent.JOYSTICK_BUTTON and event.button_index == JOY_START:
		just_pressed = !start_pressed
		start_pressed = true
	elif start_pressed:
		start_pressed = false
		just_released = true
		
	if just_released:
		if get_tree().is_paused():
			#TODO HIDE PROMPT
			get_tree().set_pause(false)
		else:
			#TODO SHOW PROMPT
			get_tree().set_pause(true)
			
	if get_tree().is_paused():
		if event.type == InputEvent.JOYSTICK_BUTTON and event.button_index == JOY_XBOX_A: #QUIT
			get_tree().set_pause(false)
			globals.goto_scene("res://menu.tscn")
