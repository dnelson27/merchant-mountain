extends Node

class_name ExpensesController

class Expense:
	var name = "ERROR"
	var daily_cost = 0
	func _init(expense_name: String, expense_daily_cost: int):
		name = expense_name
		daily_cost = expense_daily_cost


