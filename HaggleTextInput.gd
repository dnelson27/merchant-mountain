extends LineEdit

class_name HaggleTextInput

var haggle_price_submit_button: HagglePriceSubmitButton

# Called when the node enters the scene tree for the first time.
func _ready():
	haggle_price_submit_button = get_parent().get_node("HagglePriceSubmitButton")
	self.text_submitted.connect(_text_submitted)

func _text_submitted(val):
	haggle_price_submit_button.haggle_submit_pressed.emit()
	
