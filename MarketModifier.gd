extends Node

class_name MarketModifier

var rng = RandomNumberGenerator.new()

# Type price modifiers
var weapon_type_modifier = 100
var potion_type_modifier = 50

# Rarity variance calc
var rarity_variance_min_medium = 0
var rarity_variance_max_medium = 15
var rarity_variance_min_high = 0
var rarity_variance_max_high = 25
var medium_rarity = 5
var high_rarity = 7

# Item type pull modifiers

class ItemTypePullModifiers extends Node:
	var weights = {
		"weapon_type_weight": 0.3,
		"potion_type_weight": 0.3,
		"mount_type_weight": 0.4,
	}
	
	func change_weight(key: String, delta: float):
		print("Increasing %s by %s" % [key, str(delta)])
		# Calculate the total sum of variables before adjustment
		var total_sum = _total_weight_value()

		# Calculate the current value of the variable to be adjusted
		var current_value = weights[key]

		# Calculate the change required for the variable to be adjusted
		var change = delta - current_value

		# Update the variable to be adjusted
		weights[key] = delta

		# Adjust the other two variables proportionally
		var remaining_sum = 1.0 - delta
		var proportional_change = change / remaining_sum
		
		_adjust_all_weights_proportional(proportional_change, key)
		
		print("WEIGHTS %s" % str(weights))

	func _adjust_all_weights_proportional(proportional_change: float, ignore_key: String):
		for key in weights:
			if key != ignore_key:
				weights[key] -= weights[key] * proportional_change

	func _total_weight_value() -> float:
		var total_weight_value = 0
		for key in weights:
			total_weight_value += weights[key]
		return total_weight_value
	
	func get_weight(key):
		return weights[key]

var item_type_pull_modifiers = ItemTypePullModifiers.new()

# Modifies the provided base price with the updated market conditions
func calculate_owned_item_price(purchase_base_price: int, attributes: Dictionary) -> int:
	return purchase_base_price + _owned_item_modifier(attributes)

# Returns the base price (which cannot be adjusted later) along with the adjusted price (which can be adjusted later)
func calculate_new_item_price(attributes: Dictionary) -> Dictionary:
	var base_price = item_rarity_modifier(attributes)
	var adjusted_price = base_price + _type_modifier(attributes)
	return {
		"base_price": base_price,
		"adjusted_price": adjusted_price
	}
	
func price_with_markup(attributes, bought_price) -> int:
	return bought_price # TODO add optional markup
	
func _owned_item_modifier(attributes: Dictionary):
	return _type_modifier(attributes)

func item_rarity_modifier(attributes) -> int:
	var modifier = 0
	var rarity = attributes["rarity"]
	if rarity != null:
		modifier = (10 * rarity) + (_rarity_variance(rarity) * randi_range(1, -1))
	return modifier
	
func _rarity_variance(rarity: int):
	if rarity <= medium_rarity:
		return rng.randi_range(rarity_variance_min_medium, rarity_variance_max_medium)
	if rarity <= high_rarity:
		return rng.randi_range(rarity_variance_min_high, rarity_variance_max_high)
	return rng.randi_range(0, 40)
	
func _type_modifier(attributes) -> int:
	match attributes["type"]:
		"weapon":
			return weapon_type_modifier
		"potion":
			return potion_type_modifier
	return 25
