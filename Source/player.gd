extends Node2D

export(int) var gravity = 98
export(int) var speed = 20

enum STATES {
	default,
	attack,
	action,
	fixing
}

var fixing_box = null

var last_fixed = 0

var state = STATES.default

var velocity = Vector2()

var fixing_pos = Vector2()

var last_fixed_instance = null

onready var state_change_at = OS.get_ticks_msec()

var touching_other_player = false
var other_player = null

func _ready():
	get_node("Node2D/Body/PlayerTriggerStatic").connect("body_enter", self, "on_body_enter")
	get_node("Node2D/Body/PlayerTriggerStatic").connect("body_exit", self, "on_body_exit")
	
	self.set_fixed_process(true)

func on_body_enter(body):
	if body.get_name() == "Player" and not body == self:
		self.touching_other_player = true
		self.other_player = body

func on_body_exit(body):
	if body.get_name() == "Player" and not body == self:
		self.touching_other_player = false
		self.other_player = null

func set_state(state, opt):
	self.state = state
	self.state_change_at = OS.get_ticks_msec()
	
	if state == STATES.fixing:
		self.fixing_box = opt
		self.fixing_pos = self.get_pos()

func is(check_state):
	return self.state == STATES.action

func process_default(delta):
	pass


func process_attack(delta):
	pass

func process_fixing(delta):
	if self.fixing_box != null:
		#self.set_pos(self.fixing_pos)
		self.set_global_pos(self.fixing_box.get_global_pos())

func action_pressed():
	if state == STATES.default:
		self.set_state(STATES.action, null)

func action_released():
	if state == STATES.fixing or state == STATES.action:
		self.set_state(STATES.default, null)
		self.fixing_box = null

func fixed_box():
	self.set_state(STATES.default, null)
	self.fixing_box.get_parent().fixed(self.fixing_box, self)
	self.last_fixed = self.fixing_box.get_parent().pole_index
	self.last_fixed_instance = self.fixing_box.get_parent()
	var line = self.get_parent().get_parent().get_node("Level").get_line_for_team(self.get_parent().team)
	line.add_pole(self.fixing_box.get_parent(), self.fixing_box.get_global_pos().y)
	self.get_parent().get_parent().get_node("Level").check_lines()
	self.fixing_box = null

func _fixed_process(delta):
	if (state == STATES.default):
		process_default(delta)
	elif (state == STATES.attack):
		if OS.get_ticks_msec() - self.state_change_at > 1000:
			self.set_state(STATES.default, null)
		process_attack(delta)
	elif (state == STATES.fixing):
		if OS.get_ticks_msec() - self.state_change_at > 4000:
			self.fixed_box()
		process_fixing(delta)
	elif (state == STATES.action):
		if OS.get_ticks_msec() - self.state_change_at > 700:
			self.set_state(STATES.default, null)
		
		if touching_other_player:
			self.set_state(STATES.attack, null)
			self.other_player.apply_impulse(self.other_player.get_global_pos(), self.get_parent().velocity * 100)
	
	#todo remove
	update()

func _draw():
	var color = null 
	if self.state == STATES.action:
		color = Color(255, 0, 0)
	elif self.state == STATES.fixing:
		color = Color(0, 255, 0)
	elif self.state == STATES.default:
		color = Color(0, 0, 255)
	elif self.state == STATES.attack:
		color = Color(1, 1, 0)
	else:
		print ("WTF", self.state)
	
	if color != null:
		#draw_set_transform_matrix(get_global_transform().affine_inverse())
		draw_circle(self.get_pos(), 5, color)