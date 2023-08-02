extends MenuHandler

class_name EventMenuHandler

signal show_event_menu(event: MarketEvents.Event)

var event_menu_container: VBoxContainer
var continue_button: EventMenuContinueButton

func _ready():
	event_menu_container = get_parent().get_parent().get_parent().get_node("Control/EventMenu/EventMenuContainer")
	parent_margin_container = get_parent().get_parent().get_parent().get_node("Control/EventMenu")
	continue_button = get_parent().get_parent().get_parent().get_node("Control/EventMenu/EventMenuContainer/EventMenuContinueButton")
	continue_button.event_continue_clicked.connect(_clear)
	self.show_event_menu.connect(_show_menu)
	parent_margin_container.visible = false
	
func _show_menu(event: MarketEvents.Event):
	parent_margin_container.visible = true
	event_menu_container.add_child(_new_label(event.display_details))
