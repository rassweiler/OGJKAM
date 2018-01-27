extends Node2D

export(int) var chain_count = 10
export(int) var max_length = 100

export(NodePath) var node_from 
export(NodePath) var node_to

onready var segment_size = max_length/chain_count

var chains = []
var pivots = []

func create_segments():
	var last_pos = self.node_from.get_pos()
	
	var first_pivot = PinJoint2D()
	self.pivots.append(first_pivot)
	first_pivot.set_node_a(self.node_from)
	
	for i in range(self.chain_count):
		var chain = RigidBody2D()
		chain.set_pos(last_pos)
		chain.set_size(Vector2(5, self.segment_size))
		
		last_pos.y += self.segment_size
		
		if (i == 0):
			first_pivot.set_node_b(chain)
		
		self.add_child(chain)
		self.chains.append(chain)
	
	for i in range(0, self.chain_count, 2):
		var pivot = PinJoint2D()
		self.pivots.append(pivot)
		pivot.set_node_a(self.chains[i])
		pivot.set_node_b(self.chains[i+1])
	
	var last_pivot = PinJoint2D()
	self.pivots.append(last_pivot)
	last_pivot.set_node_a(self.chains[-1])
	last_pivot.set_node_b(self.node_to)
	
	self.node_to.set_pos(self.chains[-1].get_pos())

func _ready():
	self.create_segments()
	
	self.set_process(true)

func _draw():
	for chain in self.chains:
		self.draw_rect(Rect2(chain.get_pos().x, chain.get_pos().y, chain.get_size().x, chain.get_size().y), Color(255, 0, 0))

func _process(delta):
	#self.refresh_chain_pos()
	update()