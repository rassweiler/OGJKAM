extends Node2D

export(int) var max_speed = 250
export(int) var acceleration = 20
export(int) var reverse_acceleration = 10

enum STATES {
	default
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
	var forward_acceleration_modifier = Input.get_joy_axis(0, JOY_AXIS_7)
	var reverse_acceleration_modifier = Input.get_joy_axis(0, JOY_AXIS_6)
	
	if (forward_acceleration_modifier > .1):
		self.velocity.x += self.acceleration * delta
		
	if (reverse_acceleration_modifier > .1):
		self.velocity.x -= self.reverse_acceleration * delta  
	
	if (forward_acceleration_modifier == 0 and reverse_acceleration_modifier == 0):
		pass
		#self.velocity.x -=
	
	var position = self.get_pos()
	position.x += self.velocity.x * delta
	
	position.x = clamp(position.x, -self.max_speed, self.max_speed)
	
	self.set_pos(position)

func _fixed_process(delta):
	if (state == STATES.default):
		process_default(delta)

