extends Button

class_name StoreManagementButton

signal store_management_button_pressed

func _pressed():
	store_management_button_pressed.emit()
