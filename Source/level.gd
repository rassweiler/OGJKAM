extends Node2D

var Ground = preload("res://Ground.tscn")
var UtilityPole = preload("res://UtilityPole.tscn")

export(int) var screens = 20
export(int) var pole_density = 1
export(int) var pole_x_variance = 200

var terrain = []
var poles = []

func build_screen():
	var screen = Ground.instance()
	
	self.add_child(screen)
	
	return screen
	
func build_pole():
	var pole = UtilityPole.instance()
	
	self.add_child(pole)
	
	return pole

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
