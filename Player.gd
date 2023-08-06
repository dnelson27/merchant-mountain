extends Node

class_name Player

signal player_sold(item)
signal player_bought(item)

var stock = {}
var money = 0
var skills: Skills
var upgrade_controller: UpgradeController

func _ready():
	upgrade_controller = get_parent().get_node("UpgradeController")
	skills = get_node("Skills")
	upgrade_controller.destroy_item.connect(_remove_stock)

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
