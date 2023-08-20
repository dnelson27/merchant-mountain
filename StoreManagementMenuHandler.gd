extends MenuHandler

class_name StoreManagementMenuHandler

signal show_store_management_menu

var upgrades_container: VBoxContainer
var expenses_container: VBoxContainer
var exit_button: StoreManagementExitButton
var store_management_button: StoreManagementButton
var skills: Skills
var expenses_controller: ExpensesController
var debt_controller: DebtController
var player: Player

class PayDebtButton extends Button:
	var debt
	signal debt_pay_attempted(debt)
	
	func _ready():
		self.pressed.connect(_button_pressed)
	
	func _button_pressed():
		debt_pay_attempted.emit(debt)
		
	func _init(button_debt: DebtController.Debt):
		debt = button_debt
		text = "Pay Debt"

class SkillUpgradeButton extends Button:
	var skill
	signal upgrade_attempted(skill)
	
	func _process(delta):
		if skill != null:
			var current_state = "Upgrade for %s" % skill.upgrade_price
			if current_state != text:
				text = current_state
	
	func _ready():
		var id
		self.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		self.pressed.connect(_emit_upgrade_attempt)
	
	func _emit_upgrade_attempt():
		upgrade_attempted.emit(skill)
		
	func _init(button_skill: Skills.Skill):
		skill = button_skill
		text = "Upgrade for %s" % skill.upgrade_price

# Contains a MarginContainer with an inner RichTextLabel
class StoreManagementRow extends HBoxContainer:
	func _init(label_container: MarginContainer, new_button: Button):
		super()
		self.add_child(label_container)
		if new_button != null:
			self.add_child(new_button)
		# Shrink Vert Fill Horizontal
		self.size_flags_horizontal = Control.SIZE_FILL
		self.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

func _new_upgrade_row(skill: Skills.Skill, button: Button) -> StoreManagementRow:
	var res = StoreManagementRow.new(
		_new_labeL_container("%s: Level %s" % [skill.display_name, skill.level]),
		button,
	)
	nodes_to_dequeue.append(res)
	return res

func _new_expense_row(expense: ExpensesController.Expense):
	var description = expense.name
	if expense.daily_cost != 0:
		description += " Daily Cost: %s;" % str(expense.daily_cost)
	if expense.weekly_cost != 0:
		description += " Weekly Cost: %s;" % str(expense.weekly_cost)
	
	var res = StoreManagementRow.new(
		_new_labeL_container(description),
		null,
	)
	nodes_to_dequeue.append(res)
	return res

func _new_debt_row(debt: DebtController.Debt, button: PayDebtButton):
	var description = "DEBT: %s of %s needs to be paid in %s days" % [debt.display_name, debt.unpaid_amount, debt.days_to_pay]
	var res = StoreManagementRow.new(
		_new_labeL_container(description),
		button,
	)
	nodes_to_dequeue.append(res)
	return res

func _new_skill_upgrade_button(skill: Skills.Skill) -> SkillUpgradeButton:
	var res = SkillUpgradeButton.new(skill)
	nodes_to_dequeue.append(res)
	return res

func _new_debt_pay_button(debt: DebtController.Debt) -> PayDebtButton:
	var res = PayDebtButton.new(debt)
	nodes_to_dequeue.append(res)
	return res

func _ready():
	player = get_parent().get_parent().get_node("Player")
	expenses_controller = get_parent().get_parent().get_node("ExpensesController")
	skills = get_parent().get_parent().get_node("Player/Skills")
	upgrades_container = get_parent().get_parent().get_parent().get_node("Control/StoreManagementMenu/StoreManagementContainer/StoreUpgradesContainer")
	expenses_container = get_parent().get_parent().get_parent().get_node("Control/StoreManagementMenu/StoreManagementContainer/ExpensesContainer")
	parent_margin_container = get_parent().get_parent().get_parent().get_node("Control/StoreManagementMenu")
	exit_button = get_parent().get_parent().get_parent().get_node("Control/StoreManagementMenu/StoreManagementContainer/StoreManagementExitButton")
	store_management_button = get_parent().get_parent().get_parent().get_node("Control/SideMenu/StoreManagementButton")
	exit_button.store_management_exit_button_cicked.connect(_clear)
	store_management_button.store_management_button_pressed.connect(_show_menu)
	debt_controller = get_parent().get_parent().get_node("DebtController")
	parent_margin_container.visible = false
	
func _show_menu():
	parent_margin_container.visible = true
	_new_upgrade_rows()
	_new_expenses_rows()
	_new_debts_rows()

func _new_debts_rows():
	for row in _debts_rows():
		expenses_container.add_child(row)

func _new_upgrade_rows():
	upgrades_container.add_child(_skill_row(skills.upgrade_skills.weapon))
	upgrades_container.add_child(_skill_row(skills.upgrade_skills.potion))
	upgrades_container.add_child(_skill_row(skills.upgrade_skills.mount))
	
func _new_expenses_rows():
	expenses_container.add_child(_calendar_row())
	for row in _expense_rows():
		expenses_container.add_child(row)
		
func _calendar_row():
	var day_number = expenses_controller.day_counter
	var day_of_week = expenses_controller.day_display_name
	var description = "Current Day %s; Next Weekly Bill In %s Days" % [day_of_week, 7 - day_number]
	var row = StoreManagementRow.new(
		_new_labeL_container(description),
		null,
	)
	nodes_to_dequeue.append(row)
	return row

func _debts_rows() -> Array:
	var result = []
	for key in debt_controller.debts:
		var debt: DebtController.Debt = debt_controller.debts[key]
		var pay_button: PayDebtButton = _new_debt_pay_button(debt)
		pay_button.debt_pay_attempted.connect(_debt_pay_attempted)
		result.append(_new_debt_row(debt, pay_button))
	return result

func _expense_rows() -> Array:
	var result = []
	for key in expenses_controller.expenses:
		var expense: ExpensesController.Expense = expenses_controller.expenses[key]
		result.append(_new_expense_row(expense))
	return result

func _skill_row(skill: Skills.Skill) -> StoreManagementRow:
	var button = _new_skill_upgrade_button(skill)
	button.upgrade_attempted.connect(_attempt_skill_upgrade)
	return _new_upgrade_row(skill, button)

func _debt_pay_attempted(debt: DebtController.Debt):
	player.attempt_debt_pay.emit(debt)

func _attempt_skill_upgrade(skill: Skills.Skill):
	skills.level_up_skill.emit(skill)
