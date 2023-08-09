extends Node

class_name UpgradeController

signal attempt_upgrade(item: TransactionController.Item)
signal recalculate_item_price(item)
signal destroy_item(item)

var player_skills: Skills

var rng = RandomNumberGenerator.new()
	
func _ready():
	player_skills = get_parent().get_node("Player/Skills")
	attempt_upgrade.connect(_attempt_upgrade)

# For the provided item, check the player's upgrade skill for that item and attempt an upgrade
# If successful, update the item with the additional upgrade value relative to the player skill. We will check add this to the selling price
# Else, remove from inventory
func _attempt_upgrade(item: TransactionController.Item):
	if item.attributes.has("upgrade_attempted"):
		return
		
	item.attributes["upgrade_attempted"] = true
	var roll = rng.randi_range(0, 10)
	match item.attributes["type"]:
		"weapon": roll += player_skills.upgrade_skills.weapon.level
		"potion": roll += player_skills.upgrade_skills.potion.level
		"mount": roll += player_skills.upgrade_skills.mount.level
		
	var rarity = item.attributes["rarity"]
	
	if roll >= rarity:
		item.attributes["rarity"] += roll
		item.attributes["upgrade_successful"] = true
		recalculate_item_price.emit(item)
		return

	destroy_item.emit(item)	
	
