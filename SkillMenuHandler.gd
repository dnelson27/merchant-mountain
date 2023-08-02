extends MenuHandler

class_name SkillMenuHandler

signal show_skill_menu

var skill_menu_container: VBoxContainer
var exit_button: SkillMenuExitButton
var skills_menu_button: SkillsButton

func _ready():
	skill_menu_container = get_parent().get_parent().get_parent().get_node("Control/SkillMenu/SkillMenuContainer")
	parent_margin_container = get_parent().get_parent().get_parent().get_node("Control/SkillMenu")
	exit_button = get_parent().get_parent().get_parent().get_node("Control/SkillMenu/SkillMenuContainer/SkillMenuExitButton")
	skills_menu_button = get_parent().get_parent().get_parent().get_node("Control/SideMenu/SkillsButton")
	exit_button.skill_menu_exit_clicked.connect(_clear)
	skills_menu_button.skills_menu_button_pressed.connect(_show_menu)
	parent_margin_container.visible = false
	
func _show_menu():
	parent_margin_container.visible = true
	parent_margin_container.add_child(_new_label("Skills"))
