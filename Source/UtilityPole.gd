extends Sprite

var pole_index = -1

var targets = {
	"GreenTarget": {
		"fixed": false
	},
	"PinkTarget": {
		"fixed": false
	}
}

func randomize_goals():
	randomize()
	var location = rand_range(0, 300)
	var gap = rand_range(30, 50)
	var which = rand_range(0, 2)
	
	var order = [get_node("GreenTarget"), get_node("PinkTarget")]
	if which == 1:
		order = [get_node("PinkTarget"), get_node("GreenTarget")]
	
	var tpos = order[0].get_pos()
	order[0].set_pos(Vector2(tpos.x, location + gap))
	tpos = order[1].get_pos()
	order[1].set_pos(Vector2(tpos.x, location - gap))
	
func fixed(box):
	targets[box.get_name()]["fixed"] = true
	box.set("visibility/visible", false)

func _ready():
	randomize_goals()
