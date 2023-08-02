extends RichTextLabel

var ui_controller: UiController

# Called when the node enters the scene tree for the first time.
func _ready():
	ui_controller = get_parent().get_parent().get_parent().get_parent().get_node("GameLogic/UiController")
	ui_controller.show_no_customer_text.connect(_show)
	ui_controller.hide_no_customer_text.connect(_hide)
	
func _show():
	self.visible = true
	
func _hide():
	self.visible = false

