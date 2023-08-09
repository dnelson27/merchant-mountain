extends Node

class_name ExpensesController

signal expense_billed(name: String, amount: int)
signal trigger_expenses

class Expense:
	var name = "ERROR"
	var daily_cost = 0
	var weekly_cost = 0 
	func _init(expense_name: String, expense_daily_cost: int, expense_weekly_cost):
		name = expense_name
		daily_cost = expense_daily_cost
		weekly_cost = expense_weekly_cost
		
var player: Player
var expenses = {}
var day_counter = 0

func _ready():
	expenses["Shop Rent"] =  Expense.new("Rent", 0, 100)
	self.trigger_expenses.connect(_trigger_expenses)
	player = get_parent().get_node("Player")

func _trigger_expenses():
	day_counter += 1
	for key in expenses:
		var e: Expense = expenses[key]
		if e.daily_cost != 0:
			expense_billed.emit(e.name, e.daily_cost)
		if day_counter == 7:
			if e.weekly_cost != 0:
				expense_billed.emit(e.name, e.weekly_cost)
			day_counter = 0
