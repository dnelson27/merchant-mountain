extends Button

class_name HagglePriceSubmitButton

signal haggle_submit_pressed

func _ready():
	self.pressed.connect(self._button_pressed)

func _button_pressed():
	haggle_submit_pressed.emit()
