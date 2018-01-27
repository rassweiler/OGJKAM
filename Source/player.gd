extends Node2D

export(int) var gravity = 98
export(int) var speed = 20

enum STATES {
	default,
	attack,
	fixing
}

var state = STATES.default

var velocity = Vector2()

var state_change_at = 0

func _ready():
	var state_change_at = OS.get_ticks_msec() 
	self.set_fixed_process(true)
	

func set_state(state):
	self.state = state
	self.state_change_at = OS.get_ticks_msec()

func process_default(delta):
	var is_action_pressed = Input.is_joy_button_pressed(0, JOY_XBOX_A)
	
	if is_action_pressed:
		self.set_state(STATES.attack)
		

func process_attack(delta):
	pass

func process_fixing(delta):
	pass

func _fixed_process(delta):
	if (state == STATES.default):
		process_default(delta)
	elif (state == STATES.attack):
		process_attack(delta)
	elif (state == STATES.fixing):
		process_fixing(delta)

