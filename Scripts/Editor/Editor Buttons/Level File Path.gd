extends Panel

@export var selector_bar : Control
@export var filepath_text : Label

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("Primary"):
		$"../../../../..".SelectListLevel($"HBoxContainer/Filepath Text".text, self)


func _on_delete_button_pressed() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(filepath_text.text))
	$"../../../../..".Unselect()
	queue_free()
