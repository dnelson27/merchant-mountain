extends RichTextLabel

class_name LoanInterestDisplay
var loan_amount_line_edit: LoanAmountLineEdit
var loan_submit_button: Button
var current_line_state = 0
var market_controller: MarketController

# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = ""
	market_controller = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("GameLogic/MarketController")
	loan_submit_button = get_parent().get_node("LoanSubmitButton")
	loan_amount_line_edit = get_parent().get_node("LoanAmountLineEdit")
	loan_amount_line_edit.text_changed.connect(_maybe_update_loan_percentage)
	loan_submit_button.pressed.connect(_submit_loan)

func _submit_loan():
	market_controller.new_loan.emit(current_line_state)
	self.text = ""

func _maybe_update_loan_percentage(new_value):
	var new_value_numeric = int(new_value)
	if new_value_numeric > 0 && new_value_numeric != current_line_state:
		self.text = str(_get_loan_interest(new_value_numeric))
	current_line_state = new_value_numeric

func _get_loan_interest(principal: int) -> int:
	return market_controller.calculate_loan_interest(principal)
