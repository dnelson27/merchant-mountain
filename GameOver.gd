extends Panel

class_name GameOver

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func make_visible():
	visible = true
