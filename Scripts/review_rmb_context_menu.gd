extends ItemList

signal search_for_tag(item_to_search)
signal create_tag(tag_to_create)

var selected_item: String = ""


@export var parents_items_popup_menu: PopupMenu
@onready var tag_reviewer = $".."

var associated_array: Array = []

func _ready():
	item_clicked.connect(parent_clicked)
	parents_items_popup_menu.id_pressed.connect(item_right_clicked)


func item_right_clicked(item_id: int) -> void:
	if item_id == 0: # Search
		search_for_tag.emit(selected_item)
	elif item_id == 1: # Create
		create_tag.emit(selected_item)


func parent_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		selected_item = self.get_item_text(index)
		
		if Tagger.tag_manager.has_tag(selected_item):
			parents_items_popup_menu.set_item_disabled(parents_items_popup_menu.get_item_index(1), true)
			parents_items_popup_menu.set_item_disabled(parents_items_popup_menu.get_item_index(0), false)
		else:
			parents_items_popup_menu.set_item_disabled(parents_items_popup_menu.get_item_index(1), false)
			parents_items_popup_menu.set_item_disabled(parents_items_popup_menu.get_item_index(0), true)
		
		parents_items_popup_menu.position = at_position + global_position
		parents_items_popup_menu.show()
	
	
func add_item_to_list(item_to_add: String) -> void:
	var can_add: bool = true
	
	if associated_array:
		if associated_array.has(item_to_add):
			can_add = false

	if not can_add:
		return
	
	add_item(item_to_add)
	associated_array.append(item_to_add)


