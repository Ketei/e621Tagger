extends ItemList


signal open_context_clicked(tag_name: String, itembox_position: Vector2, item_position: Vector2)


func _ready():
	item_clicked.connect(tag_clicked)
	empty_clicked.connect(empty_click_deselect)


func tag_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		open_context_clicked.emit(
			get_item_text(index),
			global_position,
			at_position
		)


func empty_click_deselect(_at_position: Vector2, _mouse_button_index: int) -> void:
	deselect_all()

