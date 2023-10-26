extends Control

signal add_tag_signal

@export var tags_to_add: int = 10

@onready var e6_requester_quick_search: e621Requester = $e621RequesterQuickSearch
@onready var auto_com_line_edit: LineEdit = $AutoComLineEdit
@onready var auto_complete_item_list: ItemList = $AutoCompleteItemList
@onready var cancel_auto_button = $CancelAutoButton
@onready var main_application = $"../../.."

@onready var add_auto_complete_node = $".."
@onready var add_selected_button = $AddSelectedButton
@onready var some_fix_option: OptionButton = $SomeFixOption
@onready var request_cooldown_timer = $"../RequestCooldownTimer"
@onready var tagger = $"../.."
@onready var quick_search_popup_menu: PopupMenu = $QuickSearchPopupMenu


var tag_search_array: Array[String] = [] # To be removed
var is_tagger_requesting: float = false

var tag_search_dictionary: Dictionary = {}
var list_order_array: Array = []


func _ready():
	auto_complete_item_list.item_clicked.connect(open_right_click_context_menu)
	e6_requester_quick_search.post_limit = tags_to_add + 1
	
	some_fix_option.item_selected.connect(save_search_select)
	some_fix_option.select(some_fix_option.get_item_index(Tagger.settings.tag_search_setting))
	request_cooldown_timer.timeout.connect(timer_timeout)
	e6_requester_quick_search.get_finished.connect(add_online_to_list)
	auto_com_line_edit.text_submitted.connect(search_for_tag_v2)
	cancel_auto_button.pressed.connect(add_auto_complete_node.hide)
	add_selected_button.pressed.connect(add_selected_to_list)
	quick_search_popup_menu.id_pressed.connect(activate_right_click_context_menu)

var selected_tag: String = ""


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
		main_application.go_to_create_tag(
				selected_tag, 
				[], 
				tag_search_dictionary[selected_tag]["related_tags"],
				tag_search_dictionary[selected_tag]["category"])
		add_auto_complete_node.hide()
	
	elif id_pressed == 1:
		main_application.go_to_edit_tag(selected_tag)
		add_auto_complete_node.hide()


func save_search_select(item_index: int) -> void:
	Tagger.settings.tag_search_setting = some_fix_option.get_item_id(item_index)


func add_selected_to_list() -> void:
	if not auto_complete_item_list.is_anything_selected():
		return
	
	var selected_item_list: Array = auto_complete_item_list.get_selected_items()

	for index_select in selected_item_list:
		var tag_text: String = auto_complete_item_list.get_item_text(index_select)
		add_tag_signal.emit(tag_text, false, false, tag_search_dictionary[tag_text]["related_tags"], tag_search_dictionary[tag_text]["category"])
	
	selected_item_list.reverse()
	
	
	
	for index_remove in selected_item_list:
		auto_complete_item_list.set_item_custom_bg_color(index_remove, Color.DARK_OLIVE_GREEN)
#		list_order_array.remove_at(index_remove)
#		auto_complete_item_list.remove_item(index_remove)
	
	auto_complete_item_list.deselect_all()


func search_for_tag_v2(tag_to_search: String) -> void:
	clear_all_items()
	auto_com_line_edit.editable = false
	tag_to_search = tag_to_search.replace("_", " ").strip_edges().to_lower()
	
	var tag_for_url: String = ""

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

	auto_com_line_edit.clear()
	
	e6_requester_quick_search.match_name = [tag_for_url]
	e6_requester_quick_search.get_tags()
	is_tagger_requesting = true
	request_cooldown_timer.start()


#func search_for_tag(tag_to_search: String) -> void:
#	auto_com_line_edit.editable = false
#	tag_to_search = tag_to_search.strip_edges().to_lower()
#
#	if is_tagger_requesting:
#		e6_requester_quick_search.cancel_main_request()
#
#	tag_search_array.clear()
#	auto_complete_item_list.clear()
#
#	var tag_for_url: String = ""
#
#	if some_fix_option.selected == 0:
#		tag_for_url = tag_to_search + "*"
#	elif some_fix_option.selected == 1:
#		tag_for_url = "*" + tag_to_search 
#	elif some_fix_option.selected == 2:
#		tag_for_url = "*" + tag_to_search + "*"
#
#	if some_fix_option.selected == 0:
#		for tag in Tagger.tag_manager.search_with_prefix(tag_to_search):
#			if tag_search_array.has(tag):
#				continue
#			auto_complete_item_list.add_item(tag, load("res://Textures/valid_tag.png"))
#			tag_search_array.append(tag)
#	elif some_fix_option.selected == 1:
#		for tag in Tagger.tag_manager.search_with_suffix(tag_to_search):
#			if tag_search_array.has(tag):
#				continue
#			auto_complete_item_list.add_item(tag, load("res://Textures/valid_tag.png"))
#			tag_search_array.append(tag)
#	elif some_fix_option.selected == 2:
#		for tag in Tagger.tag_manager.search_for_content(tag_to_search):
#			if tag_search_array.has(tag):
#				continue
#			auto_complete_item_list.add_item(tag, load("res://Textures/valid_tag.png"))
#			tag_search_array.append(tag)
#
#	auto_com_line_edit.clear()
#
#	e6_requester_quick_search.match_name = [tag_for_url]
#	e6_requester_quick_search.get_tags()
#	is_tagger_requesting = true
#	request_cooldown_timer.start()


func add_online_to_list(parsed_array: Array) -> void:
	is_tagger_requesting = false
	
	for e621_tag in parsed_array:
		var temp_format: e621Tag = e621_tag
		var tag_name: String = temp_format.tag_name
		
		var dictionary_build: Dictionary = {
			temp_format.tag_name: {
				"id": temp_format.id,
				"post_count": temp_format.post_count,
				"related_tags": temp_format.get_tags_with_strenght().duplicate(),
				"category": tagger.translate_category(temp_format.category),
				"is_locked": temp_format.is_locked
			}
		}
		
		if tag_search_dictionary.has(temp_format.tag_name):
			tag_search_dictionary[temp_format.tag_name]["id"] = temp_format.id
			tag_search_dictionary[temp_format.tag_name]["post_count"] = temp_format.post_count
			tag_search_dictionary[temp_format.tag_name]["related_tags"] = temp_format.get_tags_with_strenght().duplicate()
			tag_search_dictionary[temp_format.tag_name]["is_locked"] = temp_format.is_locked
		else:
			tag_search_dictionary.merge(dictionary_build)
	
	for tag in tag_search_dictionary.keys():
		if not list_order_array.has(tag):
			list_order_array.append(tag)
			auto_complete_item_list.add_item(tag, load("res://Textures/generic_tag.png"))


func clear_all_items() -> void:
	auto_com_line_edit.clear()
	auto_complete_item_list.clear()
	
	tag_search_dictionary.clear()
	auto_complete_item_list.clear()
	list_order_array.clear()

	if is_tagger_requesting:
		e6_requester_quick_search.cancel_main_request()
		is_tagger_requesting = false


func close_add() -> void: # Unused
	add_auto_complete_node.hide()


func timer_timeout() -> void:
	auto_com_line_edit.editable = true

