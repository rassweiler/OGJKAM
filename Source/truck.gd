extends Node2D

export(int) var max_speed = 250
export(int) var acceleration = 90
export(int) var reverse_acceleration = 70
export(int) var braking_acceleration = 500
export(int) var slowdown = 30;

export(int) var boom_max_speed = 250
export(int) var boom_acceleration = 70

enum STATES {
	default
}

var state = STATES.default

var velocity = Vector2()

onready var state_change_at = OS.get_ticks_msec()
onready var wheel_left = self.get_node("WheelLeft")
onready var wheel_right = self.get_node("WheelRight")

func _ready():
	self.set_fixed_process(true)
	
func set_state(state):
	self.state = state
	self.state_change_at = OS.get_ticks_msec()
	
func process_boom(delta):
	var joy_up = Input.get_joy_axis(0, JOY_AXIS_3)
	
	if (abs(joy_up) > .3):
		var boom_hook = get_node("./BoomHook")
		var boom = get_node("./BoomShaft")
		var boom_arm_shape = get_node("BoomShaft/BoomArm/CollisionShape2D");
		var shape_extents = boom_arm_shape.get_shape().get_extents()
		
		var new_rotd = boom.get_rotd() - ((5 * delta) * sign(joy_up))
		var x = shape_extents.x * 2; #x
		
		#var y_deg = 180 - (new_rotd + 90)
		
		var y = tan(deg2rad(new_rotd)) * x
		
		#var hypotenuse = sqrt(x*x + y*y)
		print("SET Y", y)
		
		var cpos = boom_hook.get_pos()
		cpos.y = boom.get_pos().y - y
		boom_hook.set_pos(cpos)
		
		boom.set_rotd(new_rotd)

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
		process_boom(delta)

