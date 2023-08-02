extends Button

class_name SkillsButton

signal skills_menu_button_pressed

func _pressed():
	skills_menu_button_pressed.emit()
