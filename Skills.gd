extends Node

class_name Skills

# TODO maybe skills should only be purchaseable?? maybe you just upgrade your tools

signal level_up_skill(skill: Skills.Skill)

var upgrade_skills: UpgradeSkills
var player: Player

enum SkillKey {WEAPON_UPGRADE, POTION_UPGRADE, MOUNT_UPGRADE}

class Skill:
	var level = 0
	var label = "ERROR"
	var upgrade_price = 0
	var display_name = _display_name()
	
	func _init(starting_level: int, new_label: SkillKey, starting_upgrade_price: int):
		level = starting_level
		label = new_label
		upgrade_price = starting_upgrade_price
	
	func _display_name() -> String:
		match label:
			SkillKey.WEAPON_UPGRADE: return "Weapon Upgrade"
			SkillKey.POTION_UPGRADE: return "Potion Upgrade"
			SkillKey.MOUNT_UPGRADE: return "Mount Upgrade"
		return "ERROR"

# Each value is added to the roll during an upgrade for that type
class UpgradeSkills:
	var weapon: Skill = Skill.new(0, SkillKey.WEAPON_UPGRADE, 100)
	var potion: Skill = Skill.new(0, SkillKey.POTION_UPGRADE, 100)
	var mount: Skill = Skill.new(0, SkillKey.MOUNT_UPGRADE, 100)

func _maybe_upgrade_skill(skill: Skill):
	print("Attempted upgrade")
	if player.money >= skill.upgrade_price:
		player.skill_upgrade_expense.emit("%s Skill Upgrade" % skill.display_name,  skill.upgrade_price)
		skill.level += 1
		skill.upgrade_price *= 2

func _ready():
	upgrade_skills = UpgradeSkills.new() # TODO can load from filesystem later
	player = get_parent()
	self.level_up_skill.connect(_maybe_upgrade_skill)
