extends ItemList


signal open_context_clicked(
		tag_name: String,
		itembox_position: Vector2,
		item_position: Vector2,
		is_delete_allowed,
		reference,
		item_index)

@export var can_remove: bool = false


func _ready():
	item_clicked.connect(tag_clicked)
	empty_clicked.connect(empty_click_deselect)


func tag_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		open_context_clicked.emit(
			get_item_text(index),
			global_position,
			at_position,
			can_remove,
			self,
			index
		)


func empty_click_deselect(_at_position: Vector2, _mouse_button_index: int) -> void:
	deselect_all()


func remove_item_from_list(item_index: int) -> void:
	#var item_text: String = get_item_text(item_index)
	remove_item(item_index)
	
	
#func add_item_to_list(item_to_add: String) -> void:
	#var can_add: bool = true
	#
	#if associated_array:
		#if associated_array.has(item_to_add):
			#can_add = false
	#
	#if associated_dict:
		#if associated_dict.has(item_to_add):
			#can_add = false
	#
	#if not can_add:
		#return
	#
	#add_item(item_to_add)
	#associated_array.append(item_to_add)


