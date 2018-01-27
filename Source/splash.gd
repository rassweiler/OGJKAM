extends Control
export (PackedScene) var next_scene
onready var animation_player = get_node("AnimationPlayer")

func _ready():
	animation_player.play("Splash")
	animation_player.connect("finished", self, "go_next_scene")
		
func go_next_scene():
	if(next_scene):
		add_child(next_scene.instance())
	