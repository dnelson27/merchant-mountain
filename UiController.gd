extends Node

class_name UiController

var next_customer_button: NextCustomerButton
var bottom_menu: BottomMenu
var haggle_button: HaggleButton
var customer_button: CustomerButton
var customer_text: RichTextLabel
var player: Player
var player_money: RichTextLabel
var transaction_controller: TransactionController
var HAGGLE_TAB_INDEX = 0
var CUSTOMER_TAB_INDEX = 1
var alert_window: Popup

signal refresh_customer_text
signal refresh_player_money
signal show_customer_interaction_menu
signal hide_no_customer_text
signal show_no_customer_text
signal show_haggle_already_complete

func _refresh_customer_text():
	customer_text.text = _generate_customer_text()
	
func _refresh_player_money():
	player_money.text = "Money: " + str(player.money)
	
func _generate_customer_text():
	var current_value = "No active transaction!"
	if _transaction_active():
		var sale_text = "selling" if transaction_controller.transaction.customer_selling else "buying"
		current_value = "Customer is %s a %s for %s" % [sale_text, transaction_controller.transaction.item.display_name, transaction_controller.transaction.item.customer_asking_price]
	return current_value

func _ready():
	alert_window = get_parent().get_parent().get_node("Control/AlertPopup")
	next_customer_button = get_parent().get_parent().get_node("Control/SideMenu/NextCustomerButton")
	haggle_button = get_parent().get_parent().get_node("Control/CustomerInteractionMenu/HaggleButton")
	customer_button = get_parent().get_parent().get_node("Control/CustomerInteractionMenu/CustomerButton")
	
	bottom_menu = get_parent().get_parent().get_node("Control/BottomMenu")
	customer_text = get_parent().get_parent().get_node("Control/BottomMenu/CustomerDialogue/CustomerText")
	player = get_parent().get_node("Player")
	player_money = get_parent().get_parent().get_node("Control/SideMenu/PlayerMoney")
	transaction_controller = get_parent().get_node("TransactionController")
	
	haggle_button.show_haggle_menu.connect(_show_haggle_menu)
	next_customer_button.user_next_customer_pressed.connect(_hide_no_customer_text)
	self.show_customer_interaction_menu.connect(_show_customer_interaction_menu)
	
	self.refresh_customer_text.connect(_refresh_customer_text)
	self.refresh_player_money.connect(_refresh_player_money)
	self.show_no_customer_text.connect(_show_no_customer_text)
	self.show_haggle_already_complete.connect(_show_haggle_already_complete)
	_show_customer_interaction_menu()
	
func _show_no_customer_text():
	pass

func _show_haggle_already_complete():
	var label = RichTextLabel.new()
	label.add_text("You've already completed a haggle for this customer!")
	alert_window.add_child(label)
	alert_window.visible = true
	
func _show_customer_interaction_menu():
	if transaction_controller.transaction != null && _transaction_active():
		_hide_no_customer_text()
		
	bottom_menu.current_tab = CUSTOMER_TAB_INDEX
	
func _hide_no_customer_text():
	hide_no_customer_text.emit()
	
func _show_haggle_menu():
	if _transaction_active():
		bottom_menu.current_tab = HAGGLE_TAB_INDEX

func _transaction_active() -> bool:
	return transaction_controller.transaction.status == transaction_controller.TRANSACTION_STATUS.TRANSACTION_STATUS_ACTIVE
