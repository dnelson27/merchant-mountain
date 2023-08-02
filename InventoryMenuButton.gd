extends Button

class_name InventoryMenuButton

signal populate_inventory_to_popup

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_create_menu)
	
func _create_menu():
	populate_inventory_to_popup.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
