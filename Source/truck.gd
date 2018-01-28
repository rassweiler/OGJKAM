extends Node2D

onready var globals = get_node('/root/globals')

export(int) var max_speed = 560
export(int) var acceleration = 210
export(int) var reverse_acceleration = 100
export(int) var braking_acceleration = 1400
export(int) var slowdown = 40;

export(int) var boom_max_speed = 250
export(int) var boom_acceleration = 70

export(int) var team = 0

var team_points = 0

var player_on_device = -1
var truck_on_device = -1

enum STATES {
	default
}

var state = STATES.default

var velocity = Vector2(0, 0)

onready var state_change_at = OS.get_ticks_msec()
onready var wheel_front_left = self.get_node("RealTruck/Body/WheelFrontLeft/RimFrontLeft")
onready var wheel_front_right = self.get_node("RealTruck/Body/WheelFrontRight/RimFrontRight")
onready var wheel_back_left = self.get_node("RealTruck/Body/WheelBackLeft/RimBackLeft")
onready var wheel_back_right = self.get_node("RealTruck/Body/WheelBackRight/RimBackRight")

onready var real_truck = self.get_node("RealTruck")

var player_action_pressed = false

var player_can_fix = null

var target = "GreenTarget"

onready var player = self.get_node("Player")

func _ready():
	self.determine_inputs()
	
	player_action_pressed = Input.is_joy_button_pressed(player_on_device, JOY_XBOX_A)
	
	if team == 1:
		self.target = "PinkTarget"
	
	self.get_node("Player/Node2D/Body/PlayerTriggerStatic").connect("body_enter", self, "player_trigger_body_enter")
	self.get_node("Player/Node2D/Body/PlayerTriggerStatic").connect("body_exit", self, "player_trigger_body_exit")
	
	self.set_fixed_process(true)

func player_trigger_body_enter(body):
	print(body.get_name(), self.target)
	if body.get_name() == self.target:
		print("IN TARGET")
		player_can_fix = body
		
func player_trigger_body_exit(body):
	if body.get_name() == self.target:
		print("OUT TARGET")
		player_can_fix = null
	
func determine_inputs():
	var players = globals.playersForTeam(self.team)
	
	if players.size() == 0:
		if team == 0 or team == 1:
			truck_on_device = 0
			player_on_device = 0
		return
	
	if players.size() > 1:
		for p in players:
			if p.position == 0:
				truck_on_device = p.device_id
			else:
				player_on_device = p.device_id
	else:
		truck_on_device = players[0].device_id
		player_on_device = players[0].device_id

func set_state(state):
	self.state = state
	self.state_change_at = OS.get_ticks_msec()

func process_boom(delta):
	var joy_up = Input.get_joy_axis(player_on_device, JOY_AXIS_1)
	
	var action_down = Input.is_joy_button_pressed(player_on_device, JOY_XBOX_A)
	
	if action_down:
		if not player_action_pressed: #Just pressed
			player.action_pressed()
	elif player_action_pressed: #Just released
		player.action_released()
		
	player_action_pressed = action_down
	
	if player.is(player.STATES.action) and player_action_pressed and player_can_fix != null:
		if player_can_fix.get_parent().pole_index - 1 == player.last_fixed and !player_can_fix.get_parent().targets[self.target]["fixed"]:
			player.set_state(player.STATES.fixing, player_can_fix)
	
	if (abs(joy_up) > .3) and !player.is(player.STATES.stunned):
		var boom_hook = get_node("./RealTruck/BoomHook")
		var boom_arm = get_node("./RealTruck/BoomShaft/BoomArm")
		var boom = get_node("./RealTruck/BoomShaft")
		var boom_arm_shape = get_node("./RealTruck/BoomShaft/BoomArm/CollisionShape2D");
		var shape_extents = boom_arm_shape.get_shape().get_extents()
		
		var new_rotd = boom.get_rotd() - ((15 * delta) * sign(joy_up))
		var x = shape_extents.x * 2; #x
		
		#var y_deg = 180 - (new_rotd + 90)
		
		var y = tan(deg2rad(new_rotd)) * x
		
		var hypotenuse = sqrt(x*x + y*y)
		
		var diff = hypotenuse - x
		
		boom_arm.set_pos(Vector2(diff+236, boom_arm.get_pos().y))
		
		var cpos = boom_hook.get_pos()
		cpos.y = boom.get_pos().y - y
		boom_hook.set_pos(cpos)
		
		boom.set_rotd(new_rotd)

func process_default(delta):
	var forward_acceleration_modifier = Input.get_joy_axis(truck_on_device, JOY_AXIS_7)
	var reverse_acceleration_modifier = Input.get_joy_axis(truck_on_device, JOY_AXIS_6)
	
	if (forward_acceleration_modifier > .2):
		if (self.velocity.x > 0):
			self.velocity.x += self.acceleration * forward_acceleration_modifier * delta
		else:
			self.velocity.x += self.acceleration * 1.5 * forward_acceleration_modifier * delta
		
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
	
	var position = self.real_truck.get_pos()
	self.velocity.x = clamp(self.velocity.x, -self.max_speed/2, self.max_speed*2)
	position.x += self.velocity.x * delta
	#position.y = 0
	#get_node("Player").apply_impulse(get_node("Player").get_global_pos(), velocity)
	
	if (self.velocity.x > 0):
		var mod = self.velocity.x / self.max_speed
		self.wheel_front_left.set_rotd(self.wheel_front_left.get_rotd() - 5 * mod)
		self.wheel_front_right.set_rotd(self.wheel_front_right.get_rotd() - 5 * mod)
		self.wheel_back_left.set_rotd(self.wheel_back_left.get_rotd() - 5 * mod)
		self.wheel_back_right.set_rotd(self.wheel_back_right.get_rotd() - 5 * mod)
	elif (self.velocity.x < 0):
		var mod = abs(self.velocity.x) / self.max_speed
		self.wheel_front_left.set_rotd(self.wheel_front_left.get_rotd() + 5 * mod)
		self.wheel_front_right.set_rotd(self.wheel_front_right.get_rotd() + 5 * mod)
		self.wheel_back_left.set_rotd(self.wheel_back_left.get_rotd() + 5 * mod)
		self.wheel_back_right.set_rotd(self.wheel_back_right.get_rotd() + 5 * mod)
	
	var level = globals.current_scene.get_node("Level")
		
	#position.x = clamp(position.x, level.min_x, level.max_x)

	self.real_truck.set_pos(position)

func _fixed_process(delta):
	if (state == STATES.default):
		process_default(delta)
		process_boom(delta)

