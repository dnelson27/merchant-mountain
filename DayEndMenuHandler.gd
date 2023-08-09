extends MenuHandler

class_name DayEndMenuHandler

signal show_day_end_menu
signal collect_day_end_metrics

var day_end_menu_container: VBoxContainer
var next_day_button: NextDayButton
var calendar: Calendar
var metrics: Metrics

func _input(event):
	if parent_margin_container != null:
		if parent_margin_container.visible && event is InputEventKey && event.as_text_keycode() == "Escape":
			next_day_button.next_day_clicked.emit()

func _ready():
	day_end_menu_container = get_parent().get_parent().get_parent().get_node("Control/DayEndMenu/DayEndMenuContainer")
	parent_margin_container = get_parent().get_parent().get_parent().get_node("Control/DayEndMenu")
	next_day_button = get_parent().get_parent().get_parent().get_node("Control/DayEndMenu/DayEndMenuContainer/NextDayButton")
	metrics = get_parent().get_parent().get_node("Metrics")
	calendar = get_parent().get_parent().get_node("Calendar")
	next_day_button.next_day_clicked.connect(_clear)
	self.show_day_end_menu.connect(_show_day_end_menu)
	parent_margin_container.visible = false
	
func _show_day_end_menu():
	collect_day_end_metrics.emit()
	parent_margin_container.visible = true
	day_end_menu_container.add_child(_new_label("Day %s Ended" % calendar.current_day))

	for metric_item in _generate_metric_items():
		day_end_menu_container.add_child(metric_item)
	
func _new_label(text) -> RichTextLabel:
	var label = RichTextLabel.new()
	nodes_to_dequeue.append(label)
	label.add_text(text)
	label.fit_content = true
	label.clip_contents = false
	return label

func _generate_metric_items():
	var metric_items = []
	var today_metrics = metrics.daily_metrics[len(metrics.daily_metrics) - 1]
	
	for key in today_metrics:
		var value = today_metrics[key]
		match key:
			"Bought Items":
				metric_items.append(_new_label("Items Purchased:"))
				metric_items += _display_bought_items_list(value)
			"Sold Items":
				metric_items.append(_new_label("Items Sold:"))
				metric_items += _display_sold_item_list(value)
			_:		
				metric_items.append(_new_label("%s: %s" % [key, value]))
			

	return metric_items

func _display_sold_item_list(items):
	var result = []
	for item in items:
		var profit = str(item.price_sold - item.price_bought)
		var value = "	%s sold for a profit of %s" % [item.display_name, profit]
		print(value)
		result.append(_new_label(value))
	return result

func _display_bought_items_list(items):
	var result = []
	for item in items:
		result.append(_new_label("	%s bought for %s" % [item.display_name, item.price_bought]))
	return result
