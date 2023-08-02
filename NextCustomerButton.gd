extends Button

class_name NextCustomerButton

signal user_next_customer_pressed

var ui_controller: UiController

func _ready():
	ui_controller = get_parent().get_parent().get_parent().get_node("GameLogic/UiController")
	self.pressed.connect(self._button_pressed)

func _button_pressed():
	ui_controller.show_customer_interaction_menu.emit()
	user_next_customer_pressed.emit()
