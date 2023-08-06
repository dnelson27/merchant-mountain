extends MenuHandler

class_name InventoryDisplayController

var inventory_menu_button: Button
var upgrade_controller: UpgradeController
var player: Player
var items_container: VBoxContainer
		
class ItemWindow extends Window:
	func _ready():
		var rect = self.get_visible_rect()
		self.position.x = rect.get_center().x
		self.position.y = rect.get_center().y
		self.focus_exited.connect(_close)
		self.borderless = true
		
	func _close():
		queue_free()
		
class ItemRow extends RichTextLabel:
	func _ready():
		self.clip_contents = false
		self.fit_content = true
		self.size.x = 1000
		
class ItemButton extends Button:
	var item
	var display_controller: InventoryDisplayController
	
	func _process(delta):
		if item != null:
			if item.display_name != text:
				text = item.display_name
	
	func _init(new_item, new_display_controller):
		text = new_item.display_name
		item = new_item
		display_controller = new_display_controller
		
	func _pressed():
		# Display the menu by setting visible = true
		display_controller._new_item_menu(item)

class UpgradeButton extends Button:
	var item
	var display_controller: InventoryDisplayController
	var parent_container: VBoxContainer
	var upgrade_controller: UpgradeController
	
	func _init(new_item, new_upgrade_controller: UpgradeController, new_parent_container: VBoxContainer):
		text = "Upgrade"
		item = new_item
		parent_container = new_parent_container
		upgrade_controller = new_upgrade_controller
		self.pressed.connect(_pressed)
	
	func _pressed():
		upgrade_controller.attempt_upgrade.emit(item)

func _ready():
	inventory_menu_button = get_parent().get_parent().get_parent().get_node("Control/SideMenu/InventoryMenuButton")
	inventory_menu_button.populate_inventory_to_popup.connect(_populate_inventory_to_popup)
	player = get_parent().get_parent().get_node("Player")
	upgrade_controller = get_parent().get_parent().get_node("UpgradeController")
	parent_margin_container = get_parent().get_parent().get_parent().get_node("Control/InventoryMarginContainer")
	items_container = get_parent().get_parent().get_parent().get_node("Control/InventoryMarginContainer/InventoryContainer/ItemsContainer")
	parent_margin_container.visible = false

func _populate_inventory_to_popup():
	if len(player.stock) == 0:
		return

	for key in player.stock:
		var item = player.stock[key]
		var item_button = _new_item_button(item) 
		items_container.add_child(item_button)
		
	parent_margin_container.visible = true

func _new_item_button(item) -> ItemButton:
	var result = ItemButton.new(item, self)
	nodes_to_dequeue.append(result)
	return result

func _new_upgrade_button(item, parent_container: VBoxContainer) -> UpgradeButton:
	var result = UpgradeButton.new(item, upgrade_controller, parent_container)
	nodes_to_dequeue.append(result)
	return result
	
func _new_upgrade_menu(item: TransactionController.Item, inner_parent_container: VBoxContainer):
	var window = ItemWindow.new()
#	var scroll_container = ScrollContainer.new()
	var inner_container = VBoxContainer.new()
#	scroll_container.add_child(inner_container)

	var label = ItemRow.new()
	label.add_text("Upgrade")
	inner_container.add_child(label)
	
	window.add_child(inner_container)
	
	inner_container.size.x = 15
	inner_container.size.y = 15
	window.size.x = inner_container.size.x * 1.5
	inner_parent_container.add_child(window)
	window.visible = true

func _new_item_menu(item: TransactionController.Item):
	var window = ItemWindow.new()
#	var scroll_container = ScrollContainer.new()
	var inner_container = VBoxContainer.new()
#	scroll_container.add_child(inner_container)
	
	window.add_child(inner_container)
	
	var all_attributes = {
		"Name": item.display_name,
		"Purchase Price": item.price_bought,
	}
	
	all_attributes.merge(item.attributes)
	
	var maxLen = 0
	var lines = len(all_attributes)
	
	inner_container.add_child(_new_upgrade_button(item, inner_container))
	
	for key in all_attributes:
		var label = ItemRow.new()
		var desc = "%s: %s" % [key, str(all_attributes[key])]
		if len(desc) > maxLen:
			maxLen = len(desc)
		label.add_text(desc)
		inner_container.add_child(label)
	
	inner_container.size.x = maxLen * 10
	inner_container.size.y = lines * 25

	window.size.x = inner_container.size.x * 1.5
	window.size.y = inner_container.size.y * 1.5
	
	parent_margin_container.add_child(window)
	window.visible = true
