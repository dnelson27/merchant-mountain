extends Node

class_name MarketEvents

var rng = RandomNumberGenerator.new()
var market_modifier: MarketModifier
var event_menu_handler: EventMenuHandler
var calendar: Calendar
var active_event = false

signal maybe_start_event

func _ready():
	calendar = get_parent().get_parent().get_node("Calendar")
	market_modifier = get_parent()
	maybe_start_event.connect(_maybe_random_event)
	event_menu_handler = get_parent().get_parent().get_node("UiController/EventMenuHandler")

func _maybe_random_event():	
	if active_event:
		return
	
	active_event = true
	var events = []
	var event_rarity = rng.randi_range(0, 10)
	var event_severity = rng.randi_range(0, 10)

	if event_rarity >= 5:
		events = [WarEvent]
	
	if len(events) == 0:
		return
	
	var new_event = events[rng.randi_range(0, len(events) - 1)].new(self, event_severity, calendar, market_modifier)
	new_event.invoke()
	event_menu_handler.show_event_menu.emit(new_event)

class Event extends Node:
	var day_counter = 0
	var severity
	var market_modifier: MarketModifier
	var market_events: MarketEvents
	var display_details
	
	func _init(new_market_events: MarketEvents, new_severity: int, calendar: Calendar, new_mm: MarketModifier):
		severity = new_severity
		market_events = new_market_events
		market_modifier = new_mm
		calendar.day_end.connect(_next_day)
		_set_display_details()
	
	func _next_day():
		day_counter += 1
		if day_counter == severity:
			_end_event()
			
	func _end_event():
		market_events.active_event = false
		self._undo_market_modifier_changes()
		queue_free()
		
	func _undo_market_modifier_changes():
		pass
	
	func _set_display_details():
		display_details = "ERROR"

# Increase value of weapons by 25%, increase scarcity of potions
class WarEvent extends Event:
	var original_potion_weight
	var new_potion_weight = 0.1
	var original_weapon_base_value
	func invoke():
		original_weapon_base_value = market_modifier.weapon_type_modifier
		market_modifier.weapon_type_modifier += market_modifier.weapon_type_modifier / 4
		
		print("Added %s to weapon modifier" % str(market_modifier.weapon_type_modifier / 4))
		
		original_potion_weight = market_modifier.item_type_pull_modifiers.get_weight("potion_type_weight")
		market_modifier.item_type_pull_modifiers.change_weight("potion_type_weight", new_potion_weight)
	
	func _undo_market_modifier_changes():
		market_modifier.weapon_type_modifier = original_weapon_base_value
		market_modifier.item_type_pull_modifiers.change_weight("potion_type_weight", original_potion_weight)
	
	func _set_display_details():
		# TODO add an on-screen counter and an events tab
		display_details = "WAR!! This increases the value of weapons and makes potions very scarce"
