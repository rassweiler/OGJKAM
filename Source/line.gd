extends Node2D

var pole1 = null
var pole2 = null

var team = 0

var pole1_y = 0
var pole2_y = 0

var curve = null

func _ready():
	pass

func set_pole1(pole, y):
	pole1 = pole
	pole1_y = y

func set_pole2(pole, y):
	pole2 = pole
	pole2_y = y
	create_curve()
	update()
	
func add_pole(pole, y):
	if pole1 == null:
		set_pole1(pole, y)
	elif pole2 == null:
		set_pole2(pole, y)

var draw_points = null

func create_curve():
	curve = Curve2D.new()
	
	curve.set_bake_interval(50)
	
	var p0 = Vector2(pole1.get_global_pos().x, pole1_y)
	var p3 = Vector2(pole2.get_global_pos().x, pole2_y)
	
	#find center
	var pc = ((p3-p0)/2) + p0
	
	var p1 = Vector2(-50, 50) + pc
	var p2 = pc - Vector2(-50, -50)
	
	curve.add_point(p0)
	curve.add_point(p1)
	curve.add_point(p2)
	curve.add_point(p3)
	
	draw_points = curve.tesselate()

func _draw():
	if draw_points == null:
		return
	
	var color = Color(0,0,0)
	if team == 0:
		color = Color(0, 1, 0)
	elif team == 1:
		color = Color(1, 0, 1)
	
	var last_point = null
	for point in draw_points:
		if last_point == null:
			last_point = point
			continue
		draw_line(last_point, point, color, 5)
		last_point = point