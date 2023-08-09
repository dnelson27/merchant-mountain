extends Node

class_name UiController

var rng = RandomNumberGenerator.new()
var next_customer_button: NextCustomerButton
var bottom_menu: BottomMenu
var haggle_button: HaggleButton
var customer_button: CustomerButton
var customer_text: RichTextLabel
var player: Player
var player_money: RichTextLabel
var transaction_controller: TransactionController
var haggle_dialogue: HaggleDialogue
var CUSTOMER_TAB_INDEX = 0
var alert_window: Popup
var market_modifier: MarketModifier

signal refresh_customer_text
signal refresh_player_money
signal show_customer_interaction_menu
signal hide_no_customer_text
signal show_no_customer_text
signal show_haggle_already_complete

var current_item_display_name = ""
var current_price = 0
var haggle_active = false
func _process(delta):
	if transaction_controller == null || transaction_controller.transaction == null || transaction_controller.transaction.item == null:
		return
	
	if !_transaction_active():
		customer_text.text = _generate_customer_text()
	
	if transaction_controller.transaction.item.display_name != current_item_display_name || transaction_controller.transaction.item.customer_asking_price != current_price:
		current_price = transaction_controller.transaction.item.customer_asking_price
		current_item_display_name = transaction_controller.transaction.item.display_name
		customer_text.text = _generate_customer_text()
		
	_maybe_show_haggle_menu()
	
	var player_money_str = "Money: %s" % str(player.money)
	if player_money.text != player_money_str:
		player_money.text = player_money_str
		
func _refresh_customer_text():
	customer_text.text = _generate_customer_text()
	
func _generate_customer_text():
	var current_value = "No active transaction!"
	if _transaction_active():
		var sale_text = "selling" if transaction_controller.transaction.customer_selling else "buying"
		current_value = "A %s %s is %s a %s for %s" % [ _customer_preference_value(), _customer_type_value(), sale_text, transaction_controller.transaction.item.display_name, transaction_controller.transaction.item.customer_asking_price]
	return current_value

func _customer_type_value() -> String:
	var values = [
		"Orc",
		"Elf",
		"Goblin",
		"Human",
		"Frog",
		"Turtle",
		"Fairy",
		"Penguin",
	]
	
	return values[rng.randi_range(0, len(values) - 1)]

func _customer_preference_value() -> String:
	var wiggle = transaction_controller.transaction.customer_wiggle
	if wiggle < 20:
		return "Stubborn"
	if wiggle < 35:
		return "Cautious"
	else:
		return "Gullible"
		

func _ready():
	alert_window = get_parent().get_parent().get_node("Control/AlertPopup")
	next_customer_button = get_parent().get_parent().get_node("Control/SideMenu/NextCustomerButton")
	haggle_button = get_parent().get_parent().get_node("Control/CustomerInteractionMenu/HaggleButton")
	customer_button = get_parent().get_parent().get_node("Control/CustomerInteractionMenu/CustomerButton")
	haggle_dialogue = get_parent().get_parent().get_node("Control/BottomMenu/CustomerDialogue/HaggleDialogue")
	market_modifier = get_parent().get_node("MarketModifier")
	bottom_menu = get_parent().get_parent().get_node("Control/BottomMenu")
	customer_text = get_parent().get_parent().get_node("Control/BottomMenu/CustomerDialogue/CustomerText")
	player = get_parent().get_node("Player")
	player_money = get_parent().get_parent().get_node("Control/SideMenu/PlayerMoney")
	transaction_controller = get_parent().get_node("TransactionController")
	
	haggle_button.show_haggle_menu.connect(_start_haggle)
	next_customer_button.user_next_customer_pressed.connect(_hide_no_customer_text)
	self.show_customer_interaction_menu.connect(_show_customer_interaction_menu)
	
	self.refresh_customer_text.connect(_refresh_customer_text)
	self.show_no_customer_text.connect(_show_no_customer_text)
	self.show_haggle_already_complete.connect(_show_haggle_already_complete)
	transaction_controller.haggle_completed.connect(_end_haggle)
	_show_customer_interaction_menu()
	
func _show_no_customer_text():
	pass
	
func _start_haggle():
	haggle_active = true

func _end_haggle():
	haggle_active = false

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
	
func _maybe_show_haggle_menu():
	if haggle_active:
		haggle_dialogue.visible = true
	else:
		haggle_dialogue.visible = false

func _transaction_active() -> bool:
	return transaction_controller.transaction.status == transaction_controller.TRANSACTION_STATUS.TRANSACTION_STATUS_ACTIVE
