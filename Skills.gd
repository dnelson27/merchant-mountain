extends Node

class_name Skills

var upgrade_skills: UpgradeSkills

# Each value is added to the roll during an upgrade for that type
class UpgradeSkills:
	var weapon: int
	var potion: int
	var mount: int
	
	func _init(new_weapon_skill: int, new_potion_skill: int, new_mount_skill: int):
		weapon = new_weapon_skill
		potion = new_potion_skill
		mount = new_mount_skill
		
func _ready():
	upgrade_skills = UpgradeSkills.new(0, 0, 0) # TODO can load from filesystem later
