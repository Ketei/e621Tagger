extends ItemList


signal search_for_tag(item_to_search)
signal create_tag(tag_to_create)

var selected_item: String = ""

@onready var suggestions_items_pop_up_menu = $SuggestionsItemsPopUpMenu


func _ready():
	item_clicked.connect(parent_clicked)
	suggestions_items_pop_up_menu.id_pressed.connect(item_right_clicked)


func item_right_clicked(item_id: int) -> void:
	if item_id == 0: # Search
		search_for_tag.emit(selected_item)
	elif item_id == 1: # Create
		create_tag.emit(selected_item)


func parent_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		selected_item = self.get_item_text(index)
		
		if Tagger.tag_manager.has_tag(selected_item):
			suggestions_items_pop_up_menu.set_item_disabled(suggestions_items_pop_up_menu.get_item_index(1), true)
			suggestions_items_pop_up_menu.set_item_disabled(suggestions_items_pop_up_menu.get_item_index(0), false)
		else:
			suggestions_items_pop_up_menu.set_item_disabled(suggestions_items_pop_up_menu.get_item_index(1), false)
			suggestions_items_pop_up_menu.set_item_disabled(suggestions_items_pop_up_menu.get_item_index(0), true)
		
		suggestions_items_pop_up_menu.position = at_position + global_position
		suggestions_items_pop_up_menu.show()
