extends Button

class_name SkillMenuExitButton

signal skill_menu_exit_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_pressed)

func _pressed():
	skill_menu_exit_clicked.emit()
