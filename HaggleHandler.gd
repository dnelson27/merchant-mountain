extends Node

class_name HaggleHandler

var rng = RandomNumberGenerator.new()
var haggle_price_submit_button: HagglePriceSubmitButton
var haggle_text_input: HaggleTextInput
var haggle_input: HaggleTextInput
var transaction_controller: TransactionController
var haggle_count = 0
var haggle_complete = false
var max_haggle_attempts = 3

# TODO
# Each customer should have stats that dictate the amount of wiggle they have
# The player could do a perception check to see if they can find the customers wiggle
# This check would be based on a stat, the customer might have a generic adjective like
# "Stubborn" or "Timid" that could hint at their wiggle, but the player has to check to know for sure. THese checks could be limited per day

func _ready():
	haggle_price_submit_button = get_parent().get_parent().get_node("Control/BottomMenu/CustomerDialogue/HaggleDialogue/HagglePriceSubmitButton")
	haggle_price_submit_button.haggle_submit_pressed.connect(_haggle_submit_pressed)
	transaction_controller = get_parent().get_node("TransactionController")
	transaction_controller.reset_haggle_count.connect(_reset_haggle_counter)
	haggle_text_input = get_parent().get_parent().get_node("Control/BottomMenu/CustomerDialogue/HaggleDialogue/HaggleTextInput")

func _reset_haggle_counter():
	haggle_count = 0

func _haggle_submit_pressed():
	var value = int(haggle_text_input.text)
	
	if transaction_controller.haggle_complete:
		transaction_controller.ui_controller.show_haggle_already_complete.emit()
		return
		
	if transaction_controller.transaction.status == transaction_controller.TRANSACTION_STATUS.TRANSACTION_STATUS_INACTIVE:
		transaction_controller.ui_controller.show_no_customer_text.emit()
		return
	
	if  value == 0:
		return
	
	# TODO invalid value check here and add error text to UI
	haggle_text_input.clear()
	
	var min_roll = get_haggle_min_roll(
		transaction_controller.transaction.item.customer_asking_price,
		value,
		25,
	)
	
	var roll = rng.randi_range(0, 10)
	print("Rolled %s Needed %s" % [roll, min_roll])
	if roll >= min_roll:
		transaction_controller.update_price(value)
		transaction_controller.set_haggle_complete()
	else:
		haggle_count += 1
		if haggle_count == max_haggle_attempts:
			transaction_controller.reject_transaction()
			haggle_count = 0
		

func get_haggle_min_roll(currentValue, proposedPrice, wiggle) -> int:
	# Haggle is impossible if wiggle == 0
	if wiggle == 0:
		return 11
	
	# Get the max delta from the current price based on wiggle
	var wigglePercent = float(wiggle) / 100
	var maxDelta = currentValue * wigglePercent
	var diff = abs(proposedPrice - currentValue)
	
	# If the proposed value is beyond the customer's wiggle room, haggle is impossible
	if maxDelta < diff:
		return 11

	# Get the percentage of the maxDelta that the diff represents
	var diffPercentOfWiggle = diff / maxDelta * 100

	print("DIFF PCT %s FOR %s, %s" % [diffPercentOfWiggle, maxDelta, diff])

	if diffPercentOfWiggle <= 10:
		return 3
	
	if diffPercentOfWiggle <= 20:
		return 4
	
	if diffPercentOfWiggle <= 30:
		return 5
	
	if diffPercentOfWiggle <= 40:
		return 6

	if diffPercentOfWiggle <= 50:
		return 7

	if diffPercentOfWiggle <= 60:
		return 8

	if diffPercentOfWiggle <= 70:
		return 9

	if diffPercentOfWiggle <= 80:
		return 10

	return 11

