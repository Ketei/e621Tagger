extends Control

signal add_tag_signal

@export var tags_to_get: int = 10

@onready var auto_com_line_edit: LineEdit = $AutoComLineEdit
@onready var auto_complete_item_list: ItemList = $AutoCompleteItemList
@onready var cancel_auto_button = $CancelAutoButton

#@onready var add_auto_complete_node = $".."
@onready var add_selected_button = $AddSelectedButton
@onready var some_fix_option: OptionButton = $SomeFixOption
@onready var tagger = $"../.."
@onready var quick_search_popup_menu: PopupMenu = $QuickSearchPopupMenu
@onready var quick_search = $".."



var tag_search_dictionary: Dictionary = {}
var list_order_array: Array = []
var selected_tag: String = ""

var search_queue: String = ""


func _ready():
	auto_complete_item_list.item_clicked.connect(open_right_click_context_menu)
	some_fix_option.item_selected.connect(save_search_select)
	some_fix_option.select(some_fix_option.get_item_index(Tagger.settings.tag_search_setting))
	auto_com_line_edit.text_submitted.connect(search_for_tag_v2)
	cancel_auto_button.pressed.connect(hide_autocompleter)
	add_selected_button.pressed.connect(add_selected_to_list)
	quick_search_popup_menu.id_pressed.connect(activate_right_click_context_menu)


func open_right_click_context_menu(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index != MOUSE_BUTTON_RIGHT:
		return
	
	selected_tag = auto_complete_item_list.get_item_text(index)
	var tagger_has_tag: bool = Tagger.tag_manager.has_tag(selected_tag)
	
	quick_search_popup_menu.position = at_position + Vector2(40, 368)
	quick_search_popup_menu.set_item_disabled(
			quick_search_popup_menu.get_item_index(0),
			tagger_has_tag)
	quick_search_popup_menu.set_item_disabled(
			quick_search_popup_menu.get_item_index(1),
			not tagger_has_tag)

	quick_search_popup_menu.show()


func activate_right_click_context_menu(id_pressed: int) -> void:
	if id_pressed == 0:
		tagger.main_application.go_to_create_tag(
				selected_tag, 
				[], 
				tag_search_dictionary[selected_tag]["related_tags"],
				tag_search_dictionary[selected_tag]["category"])
		hide_autocompleter()
	
	elif id_pressed == 1:
		tagger.main_application.go_to_edit_tag(selected_tag)
		hide_autocompleter()


func save_search_select(item_index: int) -> void:
	Tagger.settings.tag_search_setting = some_fix_option.get_item_id(item_index)


func add_selected_to_list() -> void:
	if not auto_complete_item_list.is_anything_selected():
		return
	
	var selected_item_list: Array = auto_complete_item_list.get_selected_items()

	for index_select in selected_item_list:
		var tag_text: String = auto_complete_item_list.get_item_text(index_select)
		# tag_name: String, tag_dict: Dictionary
		add_tag_signal.emit(tag_text, tag_search_dictionary[tag_text])
		auto_complete_item_list.set_item_custom_bg_color(index_select, Color.DARK_OLIVE_GREEN)
	
	auto_complete_item_list.deselect_all()


func search_for_tag_v2(tag_to_search: String) -> void:
	clear_all_items()
	auto_com_line_edit.release_focus()
	auto_com_line_edit.editable = false
	tag_to_search = tag_to_search.replace("_", " ").strip_edges().to_lower()
	
	var tag_for_url: String = ""
	search_queue = tag_to_search
	
	if some_fix_option.selected == 0:
		tag_for_url = tag_to_search + "*"
	elif some_fix_option.selected == 1:
		tag_for_url = "*" + tag_to_search 
	elif some_fix_option.selected == 2:
		tag_for_url = "*" + tag_to_search + "*"
	
	if some_fix_option.selected == 0:

		tag_search_dictionary = Tagger.tag_manager.search_with_prefix(tag_to_search).duplicate()
		
		for tag in tag_search_dictionary.keys():
			if not list_order_array.has(tag):
				auto_complete_item_list.add_item(tag, load("res://Textures/valid_tag.png"))
				list_order_array.append(tag)
	
	elif some_fix_option.selected == 1:
		
		tag_search_dictionary = Tagger.tag_manager.search_with_suffix(tag_to_search).duplicate()
		
		for tag in tag_search_dictionary.keys():
			if not list_order_array.has(tag):
				auto_complete_item_list.add_item(tag, load("res://Textures/valid_tag.png"))
				list_order_array.append(tag)
	
	elif some_fix_option.selected == 2:
		
		tag_search_dictionary = Tagger.tag_manager.search_for_content(tag_to_search).duplicate()
		
		for tag in tag_search_dictionary.keys():
			if not list_order_array.has(tag):
				auto_complete_item_list.add_item(tag, load("res://Textures/valid_tag.png"))
				list_order_array.append(tag)
	
	print_debug("Requesting for e621 API response for tag \"{0}\"".format([tag_for_url]))
	tagger.tag_holder.add_to_api_prio_queue(tag_for_url, 50, self)


func api_response(response_dictionary: Dictionary) -> void:
	var parsed_array: Array = response_dictionary["response"]
	
	search_queue = ""
	auto_com_line_edit.editable = true
	
	if parsed_array.is_empty():
		return
	
	var found_array = []
	
	for e621_tag in parsed_array:
		var temp_format: e621Tag = e621_tag
		if temp_format.category == e621Tag.Category.INVALID:
			continue

		var tag_name: String = temp_format.tag_name
		
		var dictionary_build: Dictionary = {
				"id": temp_format.id,
				"priority": 0,
				"parents": PackedStringArray(),
				"conflicts": PackedStringArray(),
				"post_count": temp_format.post_count,
				"related_tags": temp_format.get_tags_with_strength().duplicate(),
				"suggested_tags": PackedStringArray(),
				"category": tagger.translate_category(temp_format.category),
				"is_locked": temp_format.is_locked,
				"is_registered": Tagger.tag_manager.has_tag(tag_name)
			}
		
		if tag_search_dictionary.has(temp_format.tag_name):
			tag_search_dictionary[temp_format.tag_name]["id"] = temp_format.id
			tag_search_dictionary[temp_format.tag_name]["post_count"] = temp_format.post_count
			tag_search_dictionary[temp_format.tag_name]["related_tags"] = temp_format.get_tags_with_strength().duplicate()
			tag_search_dictionary[temp_format.tag_name]["is_locked"] = temp_format.is_locked
		else:
			tag_search_dictionary[temp_format.tag_name] = dictionary_build
	

		if not list_order_array.has(temp_format.tag_name):
#			list_order_array.append(temp_format.tag_name)
#			auto_complete_item_list.add_item(temp_format.tag_name, load("res://Textures/generic_tag.png"))
			found_array.append(temp_format.tag_name)

	found_array.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	
	for item in found_array:
		list_order_array.append(item)
		auto_complete_item_list.add_item(item, load("res://Textures/generic_tag.png"))


func clear_all_items() -> void:
	auto_complete_item_list.clear()
	
	tag_search_dictionary.clear()
	auto_complete_item_list.clear()
	list_order_array.clear()


func close_instance() -> void:
	if not search_queue.is_empty():
		tagger.tag_holder.remove_from_api_prio_queue(search_queue, self, 50)


func hide_autocompleter() -> void:
	quick_search.hide()
