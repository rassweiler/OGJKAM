extends DampedSpringJoint2D

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	update()

func _draw():
	draw_set_transform_matrix(get_global_transform().affine_inverse())
	
	var from = get_node(self.get_node_a()).get_global_pos()
	var to = get_node(self.get_node_b()).get_global_pos()
	
	self.draw_line(from, to, Color(.2, .2, .2), 3)
