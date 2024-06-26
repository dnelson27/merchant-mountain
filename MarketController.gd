extends Node

class_name MarketController

var rng = RandomNumberGenerator.new()
signal new_loan(principal)

var adjectives = [
		"Big",
		"Stinky",
		"Pre-owned",
		"Hefty",
		"Cool",
		"Cumbersome",
		"Spindly",
		"Musty",
		"Dusty",
		"Crusty",
		"Fussy",
		"Rusty",
		"Tasty",
	]


var weapon_types = [
		"Claw",
		"Sword",
		"Axe",
		"Bow",
		"Oar",
		"Tooth",
		"Goose",
		"Whip",
		"Spear",
		"Halberd",
		"Mace",
		"Hammer",
		"Club",
		"Shield",
		"Staff",
		"Pick",
		"Crossbow",
		"Atlatl",
		"Flail",
	]
	
var mount_types = [
	"Unicorn",
	"Horse",
	"Cow",
	"Man-eating Chicken",
	"Donkey",
	"Dinosaur",
	"Rock With Legs",
	"Giant Frog",
	"Turtle",
	"Dragon",
	"Unicorn",
	"Pegasus",
	"Griffin",
	"Hippogriff",
	"Dire Wolf",
	"Giant Eagle",
	"Wyvern",
	"Giant Spider",
	"War Elephant",
	"Centaur",
	"Flying Carpet",
]

var potion_types = [
	"Health",
	"Stamina",
	"Magic Fortifying",
	"Dragon Attracting",
	"Luck",
	"Growth",
	"Shrinking",
]
	
var weapon_type = "weapon"
var potion_type = "potion"
var mount_type = "mount"
var types = [weapon_type, potion_type, mount_type]

var market_modifier: MarketModifier
var upgrade_controller: UpgradeController
var debt_controller: DebtController
var player: Player

func _ready():
	player = get_parent().get_node("Player")
	debt_controller = get_parent().get_node("DebtController")
	upgrade_controller = get_parent().get_node("UpgradeController")
	market_modifier = get_parent().get_node("MarketModifier")
	upgrade_controller.recalculate_item_price.connect(_recalculate_item_price)
	self.new_loan.connect(_new_loan)

var loan_display_counter = 0
func _new_loan(principal: int):
	player.money += principal
	var total = principal + calculate_loan_interest(principal)
	
	var installment_amount = int(total / 4)
	
	var remaining_amount = total - (installment_amount * 4)
	
	loan_display_counter += 1
	debt_controller.add_debt(
		"Loan %s" % loan_display_counter,
		true,
		installment_amount + remaining_amount,
		7,
	)
	
	for i in range(2, 5):
		loan_display_counter += 1
		debt_controller.add_debt(
			"Loan %s" % loan_display_counter,
			true,
			installment_amount,
			7 * i,
		)

func _get_rarity_string(rarity: int):
	match rarity:
		2: return "Common"
		3: return "Uncommon"
		4: return "Rare"
		5: return "Fabled"
		6: return "Mythical"
		7: return "Celestial"
		8: return "Legendary"
		9: return "Divine"
		10: return "Godlike"
	return "Ordinary"

func _generate_item_name(type: String, rarity: int):
	var rarityStr = _get_rarity_string(rarity)
	var a1 = adjectives[rng.randi_range(0, len(adjectives) - 1)]
	var a2 = adjectives[rng.randi_range(0, len(adjectives) - 1)]
	var n = "thingy"
	match(type):
		weapon_type: n = weapon_types[rng.randi_range(0, len(weapon_types) - 1)]
		potion_type: n = potion_types[rng.randi_range(0, len(potion_types) - 1)] + " Potion"
		mount_type: n = mount_types[rng.randi_range(0, len(mount_types) - 1)]
	return "%s %s %s %s" % [rarityStr, a1, a2, n]

func _get_type() -> String:
	return _weighted_random_choice()

func get_customer_selling():
	if rng.randi_range(0, 10) > 5:
		return true
	return false

func _get_rarity():
	var roll = rng.randi_range(0, 100)
	if roll <= 30:
		return 1
	if roll <= 40:
		return 2
	if roll <= 50:
		return 3
	if roll <= 60:
		return 4
	if roll <= 70:
		return 5
	if roll <= 75:
		return 6
	if roll <= 80:
		return 7
	if roll <= 85:
		return 8
	if roll <= 90:
		return 9
	return 10

func generate_item(transaction_controller: TransactionController):
	var type: String = _get_type()
	var rarity: int = _get_rarity()
	var display_name = _generate_item_name(type, rarity)
	var attributes = {
		"type": type,
		"rarity": rarity,
	}
	var item_values: Dictionary = market_modifier.calculate_new_item_price(attributes)
	
	var base_price = item_values["base_price"]
	var adjusted_price = item_values["adjusted_price"]
	
	return transaction_controller.new_item(display_name, attributes, adjusted_price, base_price)

# TODO: Eventually we should unpack the player's stock and see what items would be most
# Likely to be bought in the current market
func pick_stock(transaction_controller: TransactionController):
	var stock = transaction_controller.player.stock
	var items = []
	for key in stock:
		items.append(stock[key])
	
	var stock_key = rng.randi_range(0, len(items) - 1)
	
	var item = items[stock_key]
	item.customer_asking_price = market_modifier.calculate_owned_item_price(item.base_price, item.attributes)
	return item

func _recalculate_item_price(item):
	var rarity_str = _get_rarity_string(item.attributes["rarity"])
	var name_array = item.display_name.split(" ")
	item.display_name = "%s %s %s %s" % [rarity_str, name_array[1], name_array[2], name_array[3]]
	item.base_price = market_modifier.item_rarity_modifier(item.attributes)

func _weighted_random_choice():
	var options = types
	var weights = market_modifier.item_type_pull_modifiers.weights.values()

	if options.size() != weights.size():
		printerr("Error: The number of options must be equal to the number of weights.")
		return null

	var weighted_choices = []
	for i in range(options.size()):
		var weight = int(weights[i] * 100)  # Multiply by 100 to get an integer weight
		for j in range(weight):
			weighted_choices.append(i)

	var random_index = rng.randi_range(0, weighted_choices.size()-1)
	var selected_option_index = weighted_choices[random_index]
	return options[selected_option_index]

func calculate_loan_interest(principal: int) -> int:
	return int(principal * 0.15)
