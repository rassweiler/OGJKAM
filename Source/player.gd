extends Node2D

export(int) var gravity = 98
export(int) var speed = 20

onready var globals = get_node('/root/globals')

var Sparks = preload("res://GroundSparks.tscn")

enum STATES {
	default,
	attack,
	action,
	fixing,
	stunned
}

var fixing_box = null

var last_fixed = 0

var state = STATES.default

var velocity = Vector2()

var fixing_pos = Vector2()

var last_fixed_instance = null

onready var state_change_at = OS.get_ticks_msec()

var last_stunned_at = 0

var initial_tether = Vector2()

var touching_other_player = false
var other_player = null

func _ready():
	get_node("Node2D/Body/PlayerTriggerStatic").connect("body_enter", self, "on_body_enter")
	get_node("Node2D/Body/PlayerTriggerStatic").connect("body_exit", self, "on_body_exit")
	get_node("Character01AP").play("Idle")
	initial_tether = globals.current_scene.get_node("Level").poles[0].get_global_pos()
	
	self.set_fixed_process(true)

func on_body_enter(body):
	if body.get_name() == "Player" and not body == self:
		self.touching_other_player = true
		self.other_player = body

func on_body_exit(body):
	if body.get_name() == "Player" and not body == self:
		self.touching_other_player = false
		self.other_player = null

func can_stun():
	if OS.get_ticks_msec() - last_stunned_at > 2500:
		return true
	return false

func set_state(state, opt):
	if self.state == STATES.stunned and state != STATES.default:
		return
	elif self.state == STATES.stunned:
		if ground_sparks != null:
			ground_sparks.set_emitting(false)
	
	self.state = state
	self.state_change_at = OS.get_ticks_msec()
	
	if state == STATES.fixing:
		self.fixing_box = opt
		self.fixing_pos = self.get_pos()
	elif state == STATES.action:
		get_node("Character01AP").play("Action")
		get_node("Character01AP").connect("finished", self, "animation_finished")
	elif state == STATES.attack:
		get_node("SamplePlayer2D").play("Punch")

func is(check_state):
	return self.state == check_state

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

func got_knocked():
	if state == STATES.fixing:
		self.set_state(STATES.default, null)
		self.fixing_box = null

func fixed_box():
	self.set_state(STATES.default, null)
	self.fixing_box.get_parent().fixed(self.fixing_box, self)
	self.last_fixed = self.fixing_box.get_parent().pole_index
	self.last_fixed_instance = self.fixing_box
	var line = self.get_parent().get_parent().get_node("Level").get_line_for_team(self.get_parent().team)
	line.add_pole(self.fixing_box.get_parent(), self.fixing_box.get_global_pos().y)
	self.get_parent().get_parent().get_node("Level").check_lines()
	self.fixing_box = null

var ground_sparks = null

func _fixed_process(delta):
	for body in self.get_colliding_bodies():
		if body.get_name() == "GroundBox" and self.can_stun():
			if ground_sparks == null:
				ground_sparks = Sparks.instance()
				ground_sparks.set_z(5)
				ground_sparks.set_pos(Vector2(0,0))
				self.add_child(ground_sparks)
			
			ground_sparks.set_emitting(true)
			self.set_state(STATES.stunned, null)
	
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
			self.other_player.got_knocked()
			self.other_player.apply_impulse(self.other_player.get_global_pos(), self.get_parent().velocity * 100)
			
	elif (state == STATES.stunned):
		if OS.get_ticks_msec() - self.state_change_at > 3000:
			last_stunned_at = OS.get_ticks_msec()
			self.set_state(STATES.default, null)
	
	#todo remove
	update()

func _draw():
	var color = Color(1, .5, .5, .4)
	if self.get_parent().team == 0:
		color = Color(.1, 1, .2, .4)
	draw_set_transform_matrix(get_global_transform().affine_inverse())
	
	var start = initial_tether
	if self.last_fixed_instance != null:
		start = self.last_fixed_instance.get_global_pos()
	draw_line(start, self.get_global_pos(), color, 4)
	
func animation_finished():
	get_node("Character01AP").play("Idle")
	#var color = null 
	#if self.state == STATES.action:
	#	color = Color(255, 0, 0)
	#elif self.state == STATES.fixing:
	#	color = Color(0, 255, 0)
	#elif self.state == STATES.default:
	#	color = Color(0, 0, 255)
	#elif self.state == STATES.attack:
	#	color = Color(1, 1, 0)
	#else:
	#	print ("WTF", self.state)
	
	#if color != null:
	#	#draw_set_transform_matrix(get_global_transform().affine_inverse())
	#	draw_circle(self.get_pos(), 5, color)