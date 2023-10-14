extends Control

@onready var line_edit = $LineEdit
@onready var item_list = $CurrentTags/ItemList
@onready var e_621_requester = %e621Requester
@onready var suggested_list = $Suggested/SuggestedList
@onready var clear_suggest_button = %ClearSuggestButton
@onready var tag_list_generator: TagListGenerator = %TagListGenerator
@onready var generate_list = %GenerateList
@onready var final_tag_list = $FinalTagList
@onready var implied_list = $"Implied Tags/ImpliedList"
@onready var copy_to_clipboard = %CopyToClipboard
@onready var clear_tags_button = %ClearTags
@onready var suggestions_enabled_btn: CheckButton = $SuggestionsEnabledBtn
@onready var clean_suggestions_button = $CleanSuggestionsButton


var tag_queue: Array[String] = []
var is_searching_tags: bool = false

var generic_tags: Array[String] = []
var valid_tags: Dictionary = {}
var suggestion_tags: Array[String] = []
var _implied_tags: Array[String] = []

var _full_tag_list: Array[String] = []

var suggestion_timer: Timer
var copy_timer: Timer


func _ready():
	suggestions_enabled_btn.button_pressed = Tagger.settings.search_suggested
	
	line_edit.text_submitted.connect(submit_text)
	item_list.item_activated.connect(remove_item)
	item_list.empty_clicked.connect(deselect_items)
	e_621_requester.get_finished.connect(suggestions_found)
	clear_suggest_button.pressed.connect(clear_suggestion_box)
	suggested_list.item_activated.connect(transfer_suggested)
	generate_list.pressed.connect(generate_tag_list)
	copy_to_clipboard.pressed.connect(copy_resut_to_clipboard)
	clear_tags_button.pressed.connect(clear_tags)
	suggestions_enabled_btn.toggled.connect(disable_suggested_search)
	clean_suggestions_button.pressed.connect(clean_suggestions)
	
	suggestion_timer = Timer.new()
	suggestion_timer.wait_time = 1.0
	suggestion_timer.one_shot = true
	suggestion_timer.autostart = false
	suggestion_timer.timeout.connect(search_suggested)
	add_child(suggestion_timer)
	
	copy_timer = Timer.new()
	copy_timer.wait_time = 2.0
	copy_timer.autostart = false
	copy_timer.one_shot = false
	copy_timer.timeout.connect(on_copy_timer_timeout)
	add_child(copy_timer)


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_text_delete") and item_list.is_anything_selected():
		for selected_item in item_list.get_selected_items():
			item_list.remove_item(selected_item)


func disable_suggested_search(is_toggled: bool) -> void:
	Tagger.settings.search_suggested = is_toggled


func clear_tags() -> void:
	_full_tag_list.clear()
	_implied_tags.clear()
	valid_tags.clear()
	generic_tags.clear()
	suggestion_tags.clear()
	
	item_list.clear()
	implied_list.clear()
	suggested_list.clear()


func clean_suggestions() -> void:
	for tag in _implied_tags:
		if suggestion_tags.has(tag):
			var _remove_index: int = suggestion_tags.find(tag)
			suggestion_tags.remove_at(_remove_index)
			suggested_list.remove_item(_remove_index)


func clear_suggestion_box() -> void:
	suggestion_tags.clear()
	suggested_list.clear()


func deselect_items(_at_position: Vector2, _mouse_button_index: int):
	item_list.deselect_all()


func remove_item(item_id: int) -> void:
	var _id_name: String = item_list.get_item_text(item_id)
	
	#quick_erase(_id_name, _full_tag_list)
	_full_tag_list.remove_at(item_id)
	
	if generic_tags.has(_id_name):
		quick_erase(_id_name, generic_tags)
	else:
		valid_tags.erase(_id_name)
	
	item_list.remove_item(item_id)
	regenerate_implied()


func regenerate_implied() -> void:
	_implied_tags.clear()
	implied_list.clear()
	
	tag_list_generator._dad_queue.clear()
	
	tag_list_generator._dad_queue = valid_tags.values()
	
	tag_list_generator.explore_parents()
	
	for imp_tag in tag_list_generator._kid_return:
		if _full_tag_list.has(imp_tag) or _implied_tags.has(imp_tag):
			continue		
		_implied_tags.append(imp_tag)
		implied_list.add_item(imp_tag)


func quick_erase(element_to_erase, array_ref: Array) -> void:
	if not array_ref.has(element_to_erase):
		return
	
	if element_to_erase == array_ref.back():
		array_ref.erase(element_to_erase)
		return
	
	var _index_target = array_ref.find(element_to_erase)
	
	array_ref[_index_target] = array_ref.back()
	array_ref.resize(array_ref.size() - 1)
	

func submit_text(text_to_add: String) -> void: # Adds a tag.
	text_to_add = text_to_add.to_lower().strip_edges()
	
	if text_to_add == "":
		line_edit.clear()
		return
		
	var _target_tag: String = Tagger.alias_database.get_alias(text_to_add)
	
	if Tagger.settings.invalid_tags.has(_target_tag):
		add_invalid_tag(_target_tag)
		line_edit.clear()
		return
	
		
	if _full_tag_list.has(_target_tag):
		item_list.select(_full_tag_list.find(_target_tag))
		item_list.ensure_current_is_visible()
		line_edit.clear()
		return
	
	if Tagger.tag_manager.has_tag(_target_tag):
		if not valid_tags.has(_target_tag):
			var _tag_loading = Tagger.tag_manager.get_tag(_target_tag)
			add_valid_tag(_target_tag, _tag_loading)
	else:
		add_generic_tag(_target_tag)

	line_edit.clear()

	if suggestions_enabled_btn.button_pressed:
		tag_queue.append(_target_tag)
		start_suggestion_lookup()


func button_press() -> void:
	if line_edit.text != "":
		item_list.add_item(line_edit.text)
		line_edit.clear()


func load_tags(tags_to_load: Array, replace_tags: bool) -> void:
	if replace_tags:
		item_list.clear()
		suggested_list.clear()
		implied_list.clear()
		
		_full_tag_list.clear()
		generic_tags.clear()
		valid_tags.clear()
		suggestion_tags.clear()
		_implied_tags.clear()
	
	for tag in tags_to_load:
		if tag in _full_tag_list:
			continue
		
		var _aliased: String = Tagger.alias_database.get_alias(tag)
		
		if Tagger.tag_manager.has_tag(_aliased):
			add_valid_tag(_aliased, Tagger.tag_manager.get_tag(_aliased))
		else:
			add_generic_tag(_aliased)


func start_suggestion_lookup() -> void:
	if is_searching_tags:
		return
	
	is_searching_tags = true
	search_suggested()


func search_suggested() -> void:
	e_621_requester.match_name.clear()
	e_621_requester.match_name.append(tag_queue.pop_front())
	e_621_requester.get_tags()
	

func suggestions_found() -> void:
	if not e_621_requester.response_array.is_empty():
		var tag_list: e621Tag = e_621_requester.response_array[0]

		for item in tag_list.get_tags_with_strenght():
			if suggestion_tags.has(item) or _full_tag_list.has(item):
				continue
			if not suggestion_tags.has(item) and not Tagger.settings.suggestion_blacklist.has(item):
				suggestion_tags.append(item)
				suggested_list.add_item(item)
	
	if not tag_queue.is_empty():
		suggestion_timer.start()
	else:
		is_searching_tags = false
	

func transfer_suggested(item_activated) -> void:
	var _tag_text = suggested_list.get_item_text(item_activated)
	
	if _full_tag_list.has(_tag_text):
		suggested_list.remove_item(item_activated)
		return
	
	if Tagger.tag_manager.has_tag(_tag_text):
		if not valid_tags.has(_tag_text):
			var _tag_loading = Tagger.tag_manager.get_tag(_tag_text)
			if _tag_loading:
				add_valid_tag(_tag_text, _tag_loading)
			else:
				add_generic_tag(_tag_text)
	else:
		add_generic_tag(_tag_text)
	
	if suggestions_enabled_btn.button_pressed:
		tag_queue.append(_tag_text)
		start_suggestion_lookup()


func generate_tag_list() -> void:
	tag_list_generator.generate_tag_list(valid_tags.values(), generic_tags)
	final_tag_list.text = tag_list_generator.get_tag_list()


func add_valid_tag(tag_name: String, tag_data: Tag) -> void:
	
	if _implied_tags.has(tag_name):
		var _index = _implied_tags.find(tag_name)
		implied_list.remove_item(_index)
		_implied_tags.remove_at(_index)
	
	if suggestion_tags.has(tag_name):
		var _s_index = suggestion_tags.find(tag_name)
		suggested_list.remove_item(_s_index)
		suggestion_tags.remove_at(_s_index)
	
	valid_tags[tag_name] = tag_data
	_full_tag_list.append(tag_name)
	
	tag_list_generator._dad_queue = [tag_data]
	tag_list_generator.explore_parents()
	
	for implied_parent in tag_list_generator._kid_return:
		if not _implied_tags.has(implied_parent) and not _full_tag_list.has(implied_parent):
			_implied_tags.append(implied_parent)
			implied_list.add_item(implied_parent)
	
	item_list.select(item_list.add_item(tag_name, load("res://Textures/valid_tag.png")))
	item_list.ensure_current_is_visible()


func add_generic_tag(tag_name: String) -> void:
	
	if _implied_tags.has(tag_name):
		var _index = _implied_tags.find(tag_name)
		implied_list.remove_item(_index)
		_implied_tags.remove_at(_index)
	
	if suggestion_tags.has(tag_name):
		var _s_index = suggestion_tags.find(tag_name)
		suggested_list.remove_item(_s_index)
		suggestion_tags.remove_at(_s_index)
	
	generic_tags.append(tag_name)
	_full_tag_list.append(tag_name)
	item_list.select(item_list.add_item(tag_name, load("res://Textures/generic_tag.png")))
	item_list.ensure_current_is_visible()


func add_invalid_tag(inv_tag_name: String) -> void:
	_full_tag_list.append(inv_tag_name)
	item_list.select(item_list.add_item(inv_tag_name, load("res://Textures/bad.png")))
	item_list.ensure_current_is_visible()


func copy_resut_to_clipboard() -> void:
	if final_tag_list.text == "":
		return
	
	DisplayServer.clipboard_set(final_tag_list.text)
	copy_to_clipboard.text = "Copied!"
	copy_timer.start()


func on_copy_timer_timeout() -> void:
	copy_to_clipboard.text = "Copy to Clipboard"

