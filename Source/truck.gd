extends Node2D

export(int) var max_speed = 250
export(int) var acceleration = 70
export(int) var reverse_acceleration = 40
export(int) var braking_acceleration = 140
export(int) var slowdown = 10;

enum STATES {
	default
}

var state = STATES.default

var velocity = Vector2()

var state_change_at = 0

var wheel_left = null
var wheel_right = null

func _ready():
	self.wheel_left = self.get_node("WheelLeft")
	self.wheel_right = self.get_node("WheelRight")
	
	var state_change_at = OS.get_ticks_msec() 
	self.set_fixed_process(true)
	
func set_state(state):
	self.state = state
	self.state_change_at = OS.get_ticks_msec()

func process_default(delta):
	var forward_acceleration_modifier = Input.get_joy_axis(0, JOY_AXIS_7)
	var reverse_acceleration_modifier = Input.get_joy_axis(0, JOY_AXIS_6)
	
	if (forward_acceleration_modifier > .2):
		self.velocity.x += self.acceleration * forward_acceleration_modifier * delta
		
	if (reverse_acceleration_modifier > .2):
		if (self.velocity.x > 0):
			self.velocity.x -= self.braking_acceleration * reverse_acceleration_modifier * delta
		else:
			self.velocity.x -= self.reverse_acceleration * reverse_acceleration_modifier * delta  
	
	if (forward_acceleration_modifier < .2 and reverse_acceleration_modifier < .2):
		var natural_brake = self.slowdown
		if (self.velocity.x > 0):
			natural_brake *= -1
		
		self.velocity.x += natural_brake * delta
	
	var position = self.get_pos()
	position.x += clamp(self.velocity.x, -self.max_speed, self.max_speed) * delta
	
	if (self.velocity.x > 0):
		var mod = self.velocity.x / self.max_speed
		self.wheel_left.set_rotd(self.wheel_left.get_rotd() - 5 * mod)
		self.wheel_right.set_rotd(self.wheel_right.get_rotd() - 5 * mod)
	elif (self.velocity.x < 0):
		var mod = abs(self.velocity.x) / self.max_speed
		self.wheel_left.set_rotd(self.wheel_left.get_rotd() + 5 * mod)
		self.wheel_right.set_rotd(self.wheel_right.get_rotd() + 5 * mod)
	
	self.set_pos(position)

func _fixed_process(delta):
	if (state == STATES.default):
		process_default(delta)

