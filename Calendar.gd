extends Node

class_name Calendar

var next_day_button: NextDayButton
var current_day = 0 # TODO this will come from FS eventually
signal day_end

var day_end_menu_handler: DayEndMenuHandler
var market_events_handler: MarketEvents

func _ready():
	next_day_button = get_parent().get_parent().get_node("Control/DayEndMenu/DayEndMenuContainer/NextDayButton")
	day_end_menu_handler = get_parent().get_node("UiController/DayEndMenuHandler")
	market_events_handler = get_parent().get_node("MarketModifier/MarketEvents")
	next_day_button.next_day_clicked.connect(_day_start)
	
	self.day_end.connect(_day_end)
	
func _day_start():
	market_events_handler.maybe_start_event.emit()

func _day_end():
	current_day += 1
	day_end_menu_handler.show_day_end_menu.emit()
	
