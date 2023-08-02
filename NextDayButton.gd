extends Button

class_name NextDayButton

signal next_day_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_next_day_clicked)

func _next_day_clicked():
	next_day_clicked.emit()
