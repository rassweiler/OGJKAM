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
			new_pos.x = self.goal_pos.x
		else:
			new_pos.x += cam_speed * delta
		
		cam_speed = CAMSPEED
		
		if (new_pos.y > self.goal_pos.y):
			cam_speed *= -1
		
		if (abs(new_pos.y - self.goal_pos.y) < abs(cam_speed * delta)):
			new_pos.y = self.goal_pos.y
		else:
			new_pos.y += cam_speed * delta
	
		self.set_pos(new_pos)
	if (current_zoom != self.goal_zoom):
		var new_zoom = current_zoom
		
		if (new_zoom.x > self.goal_zoom.x):
			cam_zoom_speed *= -1
		new_zoom.x += cam_zoom_speed * delta
		new_zoom.y += cam_zoom_speed * delta
		
		if (abs(new_zoom.x -  self.goal_zoom.x) < abs(cam_zoom_speed * delta)):
			new_zoom = self.goal_zoom
		
		self.set_zoom(new_zoom)
	
	var points = [
		self.get_parent().get_node("truck/RealTruck"),
		#self.get_parent().get_node("truck/Player"),
		self.get_parent().get_node("truck1/RealTruck"),
		#self.get_parent().get_node("truck1/Player")
	]
	
	self.shape = Rect2(100000, 100000, -100000, -100000)
	
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
	self.shape.size.x += 500
	
	var start = self.shape.pos
	var end = self.shape.end
	
	var size = self.shape.size
	
	var smaller_than_screen = (self.shape.size.x < 1920 && self.shape.size.y < 1080)
	
	var allow_zoom = false
	
	if (smaller_than_screen and not allow_zoom):
		self.goal_pos = Vector2(
			(self.shape.size.x/2)+start.x,
			(self.shape.size.y/2)+start.y
		)
		self.goal_pos.y = min(-300, self.goal_pos.y)
		self.goal_zoom = Vector2(1,1)
	elif (smaller_than_screen and allow_zoom):
		var scale_to = Vector2(min(self.shape.size.x, 1920), min(self.shape.size.y, 1080))
		#scale_to.x = min(1920, scale_to.x)
		#scale_to.y = min(1080, scale_to.y)
		
		var scale_factor = Vector2(scale_to.x/1920, scale_to.y/1080)
		
		var scale = min(scale_factor.x, scale_factor.y)
		
		if (scale < 0.9):
			scale = 0.9
		
		self.goal_pos = Vector2(
			(self.shape.size.x/2)+start.x,
			(self.shape.size.y/2)+start.y
		)
		
		self.goal_zoom = Vector2(scale,scale)
	else:
		var scale_to = Vector2(max(self.shape.size.x, 1920), max(self.shape.size.y, 1080))
		#scale_to.x = min(1920, scale_to.x)
		#scale_to.y = min(1080, scale_to.y)
		
		var scale_factor = Vector2(scale_to.x/1920, scale_to.y/1080)
		
		var scale = max(scale_factor.x, scale_factor.y)

		self.goal_pos = Vector2(
			(self.shape.size.x/2)+start.x,
			(self.shape.size.y/2)+start.y
		)
		
		self.goal_pos.y = min(-300*scale, self.goal_pos.y)
		
		self.goal_zoom = Vector2(scale,scale)

