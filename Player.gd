extends Node

class_name Player

signal player_sold(item)
signal player_bought(item)
signal skill_upgrade_expense(name, price)
signal attempt_debt_pay(debt)

var stock = {}
var money = 500
var skills: Skills
var upgrade_controller: UpgradeController
var expenses_controller: ExpensesController
var debt_controller: DebtController

func _ready():
	upgrade_controller = get_parent().get_node("UpgradeController")
	skills = get_node("Skills")
	debt_controller = get_parent().get_node("DebtController")
	expenses_controller = get_parent().get_node("ExpensesController")
	expenses_controller.expense_billed.connect(_expense_billed)
	upgrade_controller.destroy_item.connect(_remove_stock)
	self.skill_upgrade_expense.connect(_expense_billed)
	self.attempt_debt_pay.connect(_attempt_debt_pay)

func _expense_billed(name:String, amount: int):
	if money >= amount:
		money -= amount
		return
	else:
		var delta = amount - money
		money = 0
		# TODO get these values based on the expense name
		debt_controller.add_debt(name, true, delta, 7)
		
func _attempt_debt_pay(debt: DebtController.Debt):
	if money >= debt.unpaid_amount:
		money -= debt.unpaid_amount
		debt_controller.pay_debt(debt.id, debt.unpaid_amount)
	else:
		debt_controller.pay_debt(debt.id, money)
		money = 0

func customer_sold(item: TransactionController.Item):
	if money >= item.customer_asking_price:
		money -= item.customer_asking_price
		item.price_bought = item.customer_asking_price
		_add_stock(item)
		player_bought.emit(item)
	else:
		print("Not enough money!!")
	
func customer_bought(item):
	money += item.customer_asking_price
	item.price_sold = item.customer_asking_price
	_remove_stock(item)
	player_sold.emit(item)
	
func _add_stock(item):
	self.stock[item.id] = item

func _remove_stock(item):
	self.stock.erase(item.id)


# TODO
"""
Skills go here. Skills are used to
- Modify the market
- Attempt to upgrade items
- Manage the shop and employees
"""
