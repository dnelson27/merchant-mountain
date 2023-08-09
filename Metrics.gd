extends Node

class_name Metrics

var daily_sold_items = []
var daily_bought_items = []
var daily_metrics = []
var daily_expenses = []
var player: Player
var previous_day_money = 0
var day_end_menu_handler: DayEndMenuHandler
var expenses_controller: ExpensesController

func _ready():
	player = get_parent().get_node("Player")
	expenses_controller = get_parent().get_node("ExpensesController")
	expenses_controller.expense_billed.connect(_expense_billed)
	day_end_menu_handler = get_parent().get_node("UiController/DayEndMenuHandler")
	player.player_sold.connect(_player_sold)
	player.player_bought.connect(_player_bought)
	day_end_menu_handler.collect_day_end_metrics.connect(_collect_day_end_metrics)
	previous_day_money = player.money

func _collect_day_end_metrics():
	expenses_controller.trigger_expenses.emit()
	var metrics = {
		"Sold Items": daily_sold_items,
		"Bought Items": daily_bought_items,
		"Profit": player.money - previous_day_money,
		"Total Items Sold": len(daily_sold_items),
		"Total Items Bought": len(daily_bought_items),
	}
	metrics["Expenses"] = _format_expenses()
	previous_day_money = player.money
	daily_metrics.append(metrics)
	
	daily_bought_items = []
	daily_sold_items = []
	daily_expenses = []

func _format_expenses() -> String:
	var result = ""
	for expense in daily_expenses:
		result += "%s billed for %s " % [expense["name"], expense["amount"]]
	return result

func _player_sold(item):
	daily_sold_items.append(item)
	
func _player_bought(item):
	daily_bought_items.append(item)
	
func _expense_billed(name: String, amount: int):
	daily_expenses.append({"name": name, "amount": amount})
	
