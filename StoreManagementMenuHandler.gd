extends MenuHandler

class_name StoreManagementMenuHandler

signal show_store_management_menu

var store_management_container: VBoxContainer
var exit_button: StoreManagementExitButton
var store_management_button: StoreManagementButton
var skills: Skills

class SkillUpgradeButton extends Button:
	var skill
	signal upgrade_attempted(skill)
	
	func _process(delta):
		if skill != null:
			var current_state = "Upgrade for %s" % skill.upgrade_price
			if current_state != text:
				text = current_state
	
	func _ready():
		self.pressed.connect(_pressed)
	
	func _pressed():
		upgrade_attempted.emit(skill)
		
	func _init(button_skill: Skills.Skill):
		skill = button_skill
		text = "Upgrade for %s" % skill.upgrade_price

# Contains a MarginContainer with an inner RichTextLabel
class SkillUpgradeRow extends HBoxContainer:
	func _init(label_container: MarginContainer, new_upgrade_button: SkillUpgradeButton):
		super()
		self.add_child(label_container)
		self.add_child(new_upgrade_button)
		# Shrink Vert Fill Horizontal
		self.size_flags_horizontal = Control.SIZE_FILL
		self.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

func _new_upgrade_row(skill: Skills.Skill, button: SkillUpgradeButton) -> SkillUpgradeRow:
	var res = SkillUpgradeRow.new(
		_new_labeL_container("%s: Level %s" % [skill.display_name, skill.level]),
		button,
	)
	nodes_to_dequeue.append(res)
	return res
	
func _new_skill_upgrade_button(skill: Skills.Skill) -> SkillUpgradeButton:
	var res = SkillUpgradeButton.new(skill)
	nodes_to_dequeue.append(res)
	return res

func _ready():
	skills = get_parent().get_parent().get_node("Player/Skills")
	store_management_container = get_parent().get_parent().get_parent().get_node("Control/StoreManagementMenu/StoreManagementContainer")
	parent_margin_container = get_parent().get_parent().get_parent().get_node("Control/StoreManagementMenu")
	exit_button = get_parent().get_parent().get_parent().get_node("Control/StoreManagementMenu/StoreManagementContainer/StoreManagementExitButton")
	store_management_button = get_parent().get_parent().get_parent().get_node("Control/SideMenu/StoreManagementButton")
	exit_button.store_management_exit_button_cicked.connect(_clear)
	store_management_button.store_management_button_pressed.connect(_show_menu)
	parent_margin_container.visible = false
	
func _show_menu():
	parent_margin_container.visible = true
	_new_upgrade_rows()
	
func _new_upgrade_rows():
	store_management_container.add_child(_weapon_row())
	
func _weapon_row() -> SkillUpgradeRow:
	var button = _new_skill_upgrade_button(skills.upgrade_skills.weapon)
	button.upgrade_attempted.connect(_attempt_skill_upgrade)
	return _new_upgrade_row(skills.upgrade_skills.weapon, button)
	
func _attempt_skill_upgrade(skill: Skills.Skill):
	skills.level_up_skill.emit(skill)
