extends Node

class_name DebtController

# Debts are either created when
# 1. Player fails to pay an expense, then the unpaid amount becomes a debt
# 2. Player accepts a loan 
class Debt:
	var is_game_over_debt = false
	var unpaid_amount = 0
	var display_name = "ERROR"
	var days_to_pay = 100
	var id = 0
	
	func _init(new_id: int, new_display_name: String, new_is_game_over_debt: bool, new_unpaid_amount: int, new_days_to_pay: int):
		is_game_over_debt = new_is_game_over_debt
		days_to_pay = new_days_to_pay
		unpaid_amount = new_unpaid_amount
		display_name = new_display_name
		id = new_id

var debt_counter = 0
var calendar: Calendar
var debts = {}
var game_over: GameOver

func _new_debt_id():
	var result = debt_counter
	debt_counter += 1
	return result

func _ready():
	calendar = get_parent().get_node("Calendar")
	calendar.day_end.connect(_day_end)
	game_over = get_parent().get_parent().get_node("Control/GameOver")
	
func add_debt(display_name: String, is_game_over_debt: bool, unpaid_amount: int, days_to_pay: int):
	var id = _new_debt_id()
	debts[id] = Debt.new(id, display_name, is_game_over_debt, unpaid_amount, days_to_pay)
	
func pay_debt(id: int, amount: int):
	var debt: Debt = debts.get(id) if debts.has(id) else null
	if debt:
		debt.unpaid_amount -= amount
		if debt.unpaid_amount <= 0:
			debts.erase(id)
	
func _day_end():
	for key in debts:
		var debt: Debt = debts[key]
		if debt.days_to_pay == 0:
			if debt.is_game_over_debt:
				game_over.make_visible()
		debt.days_to_pay -= 1
