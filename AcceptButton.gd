extends Button


class_name AcceptButton

signal accept_button_pressed

func _ready():
	self.pressed.connect(self._button_pressed)

func _button_pressed():
	accept_button_pressed.emit()
