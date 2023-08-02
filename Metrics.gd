extends Node

class_name Metrics

var daily_sold_items = []
var daily_bought_items = []
var daily_metrics = []
var player: Player
var previous_day_money = 0
var day_end_menu_handler: DayEndMenuHandler

func _ready():
	player = get_parent().get_node("Player")
	day_end_menu_handler = get_parent().get_node("UiController/DayEndMenuHandler")
	player.player_sold.connect(_player_sold)
	player.player_bought.connect(_player_bought)
	day_end_menu_handler.collect_day_end_metrics.connect(_collect_day_end_metrics)
	previous_day_money = player.money

func _collect_day_end_metrics():
	var metrics = {
		"Sold Items": daily_sold_items,
		"Bought Items": daily_bought_items,
		"Profit": player.money - previous_day_money,
		"Total Items Sold": len(daily_sold_items),
		"Total Items Bought": len(daily_bought_items),
	}
	previous_day_money = player.money
	daily_metrics.append(metrics)
	
	daily_bought_items = []
	daily_sold_items = []

func _player_sold(item):
	daily_sold_items.append(item)
	
func _player_bought(item):
	daily_bought_items.append(item)
