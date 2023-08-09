extends Node

class_name Player

signal player_sold(item)
signal player_bought(item)
signal skill_upgrade_expense(name, price)

var stock = {}
var money = 150
var skills: Skills
var upgrade_controller: UpgradeController
var expenses_controller: ExpensesController

func _ready():
	upgrade_controller = get_parent().get_node("UpgradeController")
	skills = get_node("Skills")
	expenses_controller = get_parent().get_node("ExpensesController")
	expenses_controller.expense_billed.connect(_expense_billed)
	upgrade_controller.destroy_item.connect(_remove_stock)
	self.skill_upgrade_expense.connect(_expense_billed)

func _expense_billed(name:String, amount: int):
	money -= amount
	print("Billed %s for %s" % [name, amount])

func customer_sold(item: TransactionController.Item):
	money -= item.customer_asking_price
	item.price_bought = item.customer_asking_price
	_add_stock(item)
	player_bought.emit(item)
	
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
