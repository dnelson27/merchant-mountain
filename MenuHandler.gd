extends Node

class_name MenuHandler
var nodes_to_dequeue = []
var parent_margin_container: MarginContainer
	
func _new_label(text) -> RichTextLabel:
	var label = RichTextLabel.new()
	nodes_to_dequeue.append(label)
	label.add_text(text)
	label.fit_content = true
	label.clip_contents = false
	return label

func _clear():
	if len(nodes_to_dequeue) > 0:
		for node in nodes_to_dequeue:
			node.queue_free()
	nodes_to_dequeue = []
	if parent_margin_container != null:
		parent_margin_container.visible = false

func _input(event):
	if event is InputEventKey && event.as_text_keycode() == "Escape":
		_clear()
