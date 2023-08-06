extends Node

class_name TransactionController

signal new_transaction
signal reset_haggle_count
signal haggle_completed

# Transaction Class
enum TRANSACTION_STATUS {TRANSACTION_STATUS_ACTIVE, TRANSACTION_STATUS_INACTIVE}
class Transaction:
	var status 
	var item: Item
	var customer_selling: bool

	func _init(new_status: TRANSACTION_STATUS, new_item: Item, new_customer_selling: bool):
		status = new_status
		if new_status == TRANSACTION_STATUS.TRANSACTION_STATUS_INACTIVE:
			return

		item = new_item
		customer_selling = new_customer_selling
		

# Items can be upgraded using the players skills, or receive an automatic value buff after purchase
# if the player has an in-house specialist for that item type (blacksmith, mount trainer, alchemist)
# In-house specialists can only upgrade items with an item level <= their level.
# If the player attempts a DIY upgrade, they risk devaluing the item by damaging it
 
class Item:
	var id: int
	var display_name: String
	var attributes 
	var customer_asking_price: int
	var price_bought: int
	var price_sold: int
	var base_price: int

	func _init(new_id, new_display_name, new_attributes, new_customer_asking_price, new_base_price):
		id = new_id
		base_price = new_base_price
		display_name = new_display_name
		attributes = new_attributes
		customer_asking_price = new_customer_asking_price

# TransactionController class
var global_item_counter = 0
var haggle_complete = false
var next_customer_button: NextCustomerButton
var accept_button: AcceptButton
var reject_button: RejectButton
var transaction: Transaction
var market_controller: MarketController
var player: Player
var ui_controller: UiController
var calendar: Calendar
var daily_transactions = 0
var max_daily_transactions = 3

func new_item(display_name, attributes, customer_asking_price, base_price):
	var item = Item.new(global_item_counter, display_name, attributes, customer_asking_price, base_price)
	global_item_counter += 1
	return item

func _ready():
	player = get_parent().get_node("Player")
	calendar = get_parent().get_node("Calendar")
	
	next_customer_button = get_parent().get_parent().get_node("Control/SideMenu/NextCustomerButton")
	next_customer_button.user_next_customer_pressed.connect(_user_next_customer_pressed)
	
	accept_button = get_parent().get_parent().get_node("Control/CustomerInteractionMenu/AcceptButton")
	accept_button.accept_button_pressed.connect(_accept_button_pressed)
	
	reject_button = get_parent().get_parent().get_node("Control/CustomerInteractionMenu/RejectButton")
	reject_button.reject_button_pressed.connect(_reject_button_pressed)
	
	ui_controller = get_parent().get_node("UiController")
	
	market_controller = get_parent().get_node("MarketController")
	transaction = Transaction.new(TRANSACTION_STATUS.TRANSACTION_STATUS_INACTIVE, null, true)

func _accept_button_pressed():
	if transaction.status == TRANSACTION_STATUS.TRANSACTION_STATUS_ACTIVE:
		player.customer_sold(transaction.item) if transaction.customer_selling else player.customer_bought(transaction.item)
		complete_transaction()

func _reject_button_pressed():
	reject_transaction()
	
func set_haggle_complete():
	haggle_completed.emit()
	haggle_complete = true
	

func update_price(value):
	transaction.item.customer_asking_price = value
	ui_controller.refresh_customer_text.emit()
	ui_controller.show_customer_interaction_menu.emit()

func reject_transaction():
	if transaction.status == TRANSACTION_STATUS.TRANSACTION_STATUS_ACTIVE:
		complete_transaction()

func complete_transaction():
	reset_haggle_count.emit()
	ui_controller.refresh_customer_text.emit()
	ui_controller.refresh_player_money.emit()
	transaction.status = TRANSACTION_STATUS.TRANSACTION_STATUS_INACTIVE
	daily_transactions += 1
	
	if daily_transactions == max_daily_transactions:
		calendar.day_end.emit()
		daily_transactions = 0

func _user_next_customer_pressed():
	if transaction.status == TRANSACTION_STATUS.TRANSACTION_STATUS_INACTIVE:
		var selling = true
		if len(player.stock) > 0:
			selling = market_controller.get_customer_selling()
		var item = null
		if selling:
			item = market_controller.generate_item(self)
		else:
			item = market_controller.pick_stock(self) 
		transaction = Transaction.new(TRANSACTION_STATUS.TRANSACTION_STATUS_ACTIVE, item, selling)
		ui_controller.refresh_player_money.emit()
		ui_controller.refresh_customer_text.emit()
		haggle_complete = false
