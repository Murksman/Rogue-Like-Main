@tool
extends Node

# these functions quit the game.
func _input(event):
	if event.is_action("Escape") && !Engine.is_editor_hint():
		get_tree().quit()

func _notification(note_event):
	if note_event == NOTIFICATION_WM_CLOSE_REQUEST && !Engine.is_editor_hint():
		get_tree().quit()


func _on_child_entered_tree(node):
	if node is InventoryItem:
		node.item_owner = node.get_parent().get_parent()
