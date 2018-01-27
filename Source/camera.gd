extends Camera2D

var shape = Rect2(0, 0, 0, 0)

var goal_pos = Vector2(0,0)
var goal_zoom = Vector2(1,1)

const CAMSPEED = 150
const CAMZOOMSPEED = 1

func _ready():
	goal_pos = self.get_pos()
	goal_zoom = Vector2(1,1)
	
	set_process(true)

func _process(delta):
	var current_pos = self.get_pos()
	var current_zoom = self.get_zoom()
	
	var cam_speed = CAMSPEED
	var cam_zoom_speed = CAMZOOMSPEED
	
	if (current_pos != self.goal_pos):
		var new_pos = current_pos
		if (current_pos.x > self.goal_pos.x):
			cam_speed *= -1
		
		if (abs(new_pos.x - self.goal_pos.x) < abs(cam_speed * delta)):
			new_pos.x =  self.goal_pos.x
		else:
			new_pos.x += cam_speed * delta
		
		cam_speed = CAMSPEED
		
		if (new_pos.y >  self.goal_pos.y):
			cam_speed *= -1
		
		if (abs(new_pos.y -  self.goal_pos.y) < abs(cam_speed * delta)):
			new_pos.y =  self.goal_pos.y
		else:
			new_pos.y += cam_speed * delta
	
		self.set_pos(new_pos)
	if (current_zoom != self.goal_zoom):
		var new_zoom = current_zoom
		
		if (new_zoom.x >  self.goal_zoom.x):
			cam_zoom_speed *= -1
		new_zoom.x += cam_zoom_speed * delta
		new_zoom.y += cam_zoom_speed * delta
		
		if (abs(new_zoom.x -  self.goal_zoom.x) < abs(cam_zoom_speed * delta)):
			new_zoom =  self.goal_zoom
		
		self.set_zoom(new_zoom)
	
	var points = [
		self.get_parent().get_node("truck"),
		self.get_parent().get_node("player"),
		#self.get_parent().get_node("person1"),
		#self.get_parent().get_node("person2")
	]
	
	self.shape = Rect2(10000, 10000, -10000, -10000)
	
	var minx = 10000
	var miny = 10000
	var maxx = 0
	var maxy = 0
	
	for p in points:
		var pos = p.get_pos()
		
		minx = min(shape.pos.x, pos.x)
		miny = min(shape.pos.y, pos.y)
		maxx = max(shape.end.x, pos.x)
		maxy = max(shape.end.y, pos.y)
		
		self.shape = Rect2(minx, miny, maxx - minx, maxy - miny)
		
	self.shape = self.shape.grow(100)
		
		