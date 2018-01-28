extends Sprite

onready var globals = get_node('/root/globals')

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
	var location = rand_range(-50, -350)
	var gap = rand_range(60, 100)
	var which = rand_range(0, 2)
	
	var order = [get_node("GreenTarget"), get_node("PinkTarget")]
	if int(which) == 1:
		order = [get_node("PinkTarget"), get_node("GreenTarget")]
	
	var tpos = order[0].get_pos()
	order[0].set_pos(Vector2(tpos.x, location + gap))
	tpos = order[1].get_pos()
	order[1].set_pos(Vector2(tpos.x, location - gap))

func complete():
	targets["GreenTarget"]["fixed"] = true
	get_node("GreenTarget").set("visibility/visible", false)
	targets["PinkTarget"]["fixed"] = true
	get_node("PinkTarget").set("visibility/visible", false)

func fixed(box, player):
	targets[box.get_name()]["fixed"] = true
	box.set("visibility/visible", false)
	get_node("SamplePlayer2D").play("FixCompleted")
	globals.game_state.team_scored(player.get_parent().team)

func _ready():
	randomize_goals()
