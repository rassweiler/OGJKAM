extends Control
export (PackedScene) var next_scene = null

func _ready():
	$AnimationPlayer.connect("animation_finished",self,"load_scene")
	pass
	
func load_scene(vars):
	add_child(next_scene.instance())
	pass