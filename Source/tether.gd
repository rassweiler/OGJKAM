extends Node2D

export(int) var chain_count = 10
export(int) var max_length = 200

export(NodePath) var node_from_path
export(NodePath) var node_to_path

onready var node_from = self.get_node(self.node_from_path)
onready var node_to = self.get_node(self.node_to_path)

onready var segment_size = max_length/chain_count

var chains = []
var pivots = []

func create_segments():
	var last_pos = self.node_from.get_pos()
	self.set_pos(last_pos)
	
	var last_pivot_pos = self.node_from.get_pos()
	
	var first_pivot = PinJoint2D.new()
	self.pivots.append(first_pivot)
	last_pivot_pos.y += self.segment_size
	first_pivot.set_node_a(self.node_from.get_path())
	first_pivot.set_exclude_nodes_from_collision(true)
	self.node_from.add_child(first_pivot)
	
	for i in range(self.chain_count):
		var chain = RigidBody2D.new()
		chain.set_pos(last_pos)
		
		#var cshape = CollisionShape2D.new()
		
		chain.set_mass(.1)
		chain.set_bounce(1)
		chain.set_can_sleep(true)
		#body.set_linear_damp(Linear_dumping)
		#body.set_angular_damp(Angular_dumping)
		
		var shape = RectangleShape2D.new()
		shape.set_extents(Vector2(2.5, self.segment_size/2))
		
		#cshape.set_shape(shape)
		chain.add_shape(shape)
		#chain.set_name(self.get_name() + "-chain-"+ str(i))
		last_pos.y += self.segment_size
		
		self.add_child(chain)
		
		if (i == 0):
			first_pivot.set_pos(chain.get_pos())
			first_pivot.set_node_b(chain.get_path())
			
		self.chains.append(chain)
	
	for i in range(0, self.chain_count, 2):
		var pivot = PinJoint2D.new()
		self.pivots.append(pivot)
		pivot.set_pos(self.chains[i].get_pos())
		pivot.set_exclude_nodes_from_collision(true)
		last_pivot_pos.y += self.segment_size
		pivot.set_node_a(self.chains[i].get_path())
		pivot.set_node_b(self.chains[i+1].get_path())
		self.add_child(pivot)
	
	var last_pivot = PinJoint2D.new()
	self.pivots.append(last_pivot)
	last_pivot.set_pos(self.chains[-1].get_pos())
	last_pivot.set_exclude_nodes_from_collision(true)
	last_pivot.set_node_a(self.chains[-1].get_path())
	last_pivot.set_node_b(self.node_to.get_path())
	self.add_child(last_pivot)
	
	self.node_to.set_pos(self.pivots[-1].get_pos())

func _ready():
	self.create_segments()
	
	self.set_process(true)

func _draw():
	#for chain in self.chains:
	#	self.draw_rect(Rect2(chain.get_pos().x, chain.get_pos().y, 5, self.segment_size), Color(255, 0, 0))
	var current = self.pivots[0].get_pos()
	for i in range(self.chain_count):
		var next = self.pivots[-1].get_pos()
		if (i + 1 < self.chain_count):
			next = self.chains[i+1].get_pos()
		
		var angle = (current - next).angle()
		var chain = self.chains[i]
		var state = edit_get_state()
		edit_rotate(rad2deg(angle))
		self.draw_rect(Rect2(chain.get_pos().x, chain.get_pos().y, 5, self.segment_size), Color(255, 0, 0))
		edit_set_state(state)
		
		current = chain.get_pos()
	
	for pivot in self.pivots:
		self.draw_circle(pivot.get_pos(), 3, Color(0, 255, 0))

func _process(delta):
	#self.refresh_chain_pos()
	#self.node_to.set_pos(self.pivots[-1].get_pos())
	update()