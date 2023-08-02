extends Button


class_name RejectButton

signal reject_button_pressed

func _ready():
	self.pressed.connect(self._button_pressed)

func _button_pressed():
	reject_button_pressed.emit()
