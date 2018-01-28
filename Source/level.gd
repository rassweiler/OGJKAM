extends Node2D

onready var globals = get_node('/root/globals')

var Ground = preload("res://Ground.tscn")
var UtilityPole = preload("res://UtilityPole.tscn")
var Line = preload("res://line.tscn")

export(int) var screens = 10
export(int) var pole_density = 1
export(int) var pole_x_variance = 200

var terrain = []
var poles = []

var lines = []
var active_lines = []

func build_screen():
	var screen = Ground.instance()
	
	self.add_child(screen)
	
	return screen
	
func build_pole():
	var pole = UtilityPole.instance()
	
	self.add_child(pole)
	
	return pole

func get_line_for_team(team):
	for l in active_lines:
		if l.team == team:
			return l
	
	return null

func check_lines():
	var remove = []
	var add = []
	for i in range(active_lines.size()):
		var l = active_lines[i]
		if l.pole2 != null:
			self.lines.append(l)
			var line = Line.instance()
			line.team = l.team
			line.add_pole(l.pole2, l.pole2_y)
			self.add_child(line)
			remove.append(i)
			add.append(line)
	
	for r in remove:
		active_lines.remove(r)
	
	for l in add:
		active_lines.append(l)
	

func generate_level():
	for i in range(screens):
		var screen = build_screen()
		
		var pos = Vector2((i * 1920) - 960, 560)
		
		screen.set_pos(pos)
		
		terrain.append(screen)
		
		for p in range(pole_density):
			var pole = build_pole()
			
			var pole_pos = Vector2(1920.0/self.pole_density, -400)
			pole_pos.x *= p
			
			randomize()
			pole_pos.x += self.pole_x_variance * rand_range(-1, 1)
			
			pole_pos.x += pos.x
			
			pole.set_pos(pole_pos)
			
			pole.pole_index = poles.size()
			
			poles.append(pole)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	generate_level()
	
	for i in range(2):
		var line = Line.instance()
		line.team = i
		self.add_child(line)
		active_lines.append(line)
	
	var first_pole = self.poles[0]
	
	first_pole.complete()
	
	var green_line = get_line_for_team(0)
	var pink_line = get_line_for_team(1)
	
	green_line.add_pole(first_pole, first_pole.get_node("GreenTarget").get_global_pos().y)
	pink_line.add_pole(first_pole, first_pole.get_node("PinkTarget").get_global_pos().y)
	
	globals.game_state.set_pole_count(self.screens * self.pole_density)
	
	set_process(true)

func _process(delta):
	if globals.game_state.winner != null:
		pass

