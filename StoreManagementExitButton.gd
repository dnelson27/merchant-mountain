extends Button

class_name StoreManagementExitButton

signal store_management_exit_button_cicked

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_button_pressed)

func _button_pressed():
	store_management_exit_button_cicked.emit()
