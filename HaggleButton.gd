extends Button

class_name HaggleButton

signal show_haggle_menu

func _ready():
	self.pressed.connect(self._button_pressed)

func _button_pressed():
	show_haggle_menu.emit()
