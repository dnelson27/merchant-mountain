extends Button

class_name EventMenuContinueButton

signal event_continue_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_button_pressed)

func _button_pressed():
	event_continue_clicked.emit()
