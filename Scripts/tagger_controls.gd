extends Control

@onready var line_edit = $LineEdit
@onready var item_list: ItemList = $CurrentTags/ItemList
@onready var e_621_requester = %e621Requester
@onready var suggested_list = $Suggested/SuggestedList
@onready var tag_list_generator: TagListGenerator = $"../TagListGenerator"
@onready var generate_list = %GenerateList
@onready var final_tag_list = $FinalList/FinalTagList
@onready var implied_list = $"Implied Tags/ImpliedList"
@onready var copy_to_clipboard = %CopyToClipboard
@onready var clean_suggestions_button = $CleanSuggestionsButton
@onready var add_auto_complete = $AddAutoComplete
@onready var open_auto_complete_btn = $OpenAutoCompleteBTN

@onready var tagger_menu_bar: PopupMenu = $"../MenuBar/Tagger"
@onready var conflicting_tags = $ConflictingTags
@onready var main_application = $".."

@onready var clear_tags_button: Button = $ClearTagsButton
@onready var clear_suggested_button: Button = $ClearSuggestedButton
@onready var tagger_context_menu: PopupMenu = $TaggerContextMenu
@onready var warning_rect: TextureRect = $WarningRect

var tag_queue: Array[String] = []
var is_searching_tags: bool = false

#var generic_tags: Array[String] = [] # To be deleted
#var valid_tags: Dictionary = {} # To be deleted
var suggestion_tags_array: Array[String] = []
var implied_tags_array: Array[String] = []

#var _full_tag_list: Array[String] = [] # To be deleted

var final_tag_list_array: Array[String] = []

var suggestion_timer: Timer
var copy_timer: Timer

var context_menu_item_index: int = -1


# ---------- Experimental / More efficient processes -----------------------
# Instead of directly passing resources, we pass dictionaries.
# This means clean-up is simpler because the data exist in the node
# and it's more easily readable from debug. It's also easily expandable
# as dictionaries can be changed, while resources can't.
# This also means that adding suggestions can be more accurate and proactive.

const character_amounts: Array[String] = ["zero pictured", "solo", "duo", "trio", "group"]
const character_bodytypes: Array[String] = ["anthro", "semi-anthro", "feral", "humanoid", "human", "taur"]
const character_genders: Array[String] = ["male", "female", "ambiguous gender", "andromorph", "gynomorph", "herm", "maleherm"]

# Pass dictionary to list generation. Encompasses _oficial_tags & _generic_tags
var tags_inputed: Dictionary = {} 
# Only used for item list reference. Mirrors _full_tag_llsit
var full_tag_list: Array[String] = [] 

var species_added: int = 0
var genders_added: int = 0
var character_amounts_added: int = 0
var body_types_added: int = 0
var char_count_tag_set: bool = false

var implied_species_added: int = 0
var implied_genders_added: int = 0
var implied_types_added: int = 0


func append_empty_tag(tag_to_append: String) -> void:
	tags_inputed[tag_to_append] = {
		"id": -1,
		"priority": 0,
		"parents": PackedStringArray(),
		"conflicts": PackedStringArray(),
		"post_count": -1,
		"related_tags": PackedStringArray(),
		"suggested_tags": PackedStringArray(),
		"category": Tagger.Categories.GENERAL,
		"is_locked": false,
		"is_registered": false
	}


func append_registered_tag(tag_resource: Tag) -> void:
	if tags_inputed.has(tag_resource.tag):
		tags_inputed[tag_resource.tag]["priority"] = tag_resource.tag_priority
		tags_inputed[tag_resource.tag]["parents"] = PackedStringArray(tag_resource.parents.duplicate())
		tags_inputed[tag_resource.tag]["conflicts"] = PackedStringArray(tag_resource.conflicts.duplicate())
		tags_inputed[tag_resource.tag]["suggested_tags"] = PackedStringArray(tag_resource.suggestions.duplicate())
		tags_inputed[tag_resource.tag]["category"] = tag_resource.category
		tags_inputed[tag_resource.tag]["is_registered"] = true
	else:
		tags_inputed[tag_resource.tag] = {
			"id": -1,
			"priority": tag_resource.tag_priority,
			"parents": PackedStringArray(tag_resource.parents.duplicate()),
			"conflicts": PackedStringArray(tag_resource.conflicts.duplicate()),
			"post_count": -1,
			"related_tags": PackedStringArray(),
			"suggested_tags": PackedStringArray(tag_resource.suggestions.duplicate()),
			"category": tag_resource.category,
			"is_locked": false,
			"is_registered": true
		}
	
	update_parents(tag_resource)
	
	for suggestion in tag_resource.suggestions:
		add_suggested_tag(suggestion)
	
	for related_tag in tags_inputed[tag_resource.tag]["related_tags"]:
		add_suggested_tag(related_tag)
	
	add_to_category(tag_resource.category)


func append_online_data(array_with_resource: Array) -> void: # Connect tag requeter here
	var tag_resource: e621Tag = array_with_resource.front()
	
	if tags_inputed.has(tag_resource.tag_name):
		tags_inputed[tag_resource.tag_name]["id"] = tag_resource.id
		tags_inputed[tag_resource.tag_name]["post_count"] = tag_resource.post_count
		tags_inputed[tag_resource.tag_name]["related_tags"] = tag_resource.get_tags_with_strenght()
		tags_inputed[tag_resource.tag_name]["is_locked"] = tag_resource.is_locked
		
		if tags_inputed[tag_resource.tag_name]["category"] == Tagger.Categories.GENERAL and translate_category(tag_resource.category) != Tagger.Categories.GENERAL:
			tags_inputed[tag_resource.tag_name]["category"] = translate_category(tag_resource.category)
			add_to_category(translate_category(tag_resource.category))
		for tag in tag_resource.get_tags_with_strenght():
			add_suggested_tag(tag)


func add_new_tag(tag_name: String, add_from_signal: bool = true) -> void: # Connect line submit here
	tag_name = tag_name.to_lower().strip_edges()
	tag_name = tag_name.replace("_", " ")
	tag_name = Tagger.alias_database.get_alias(tag_name)
	
	if tag_name.is_empty(): # First check if empty
		if add_from_signal:
			line_edit.clear()
		return
	
	if tags_inputed.has(tag_name): # Then check if it exists already
		item_list.select(full_tag_list.find(tag_name))
		item_list.ensure_current_is_visible()
		if add_from_signal:
			line_edit.clear()
		return

	if Tagger.settings_lists.invalid_tags.has(tag_name): # Lastly, check if invalid
		item_list.add_item(tag_name, load("res://Textures/bad.png"))
		full_tag_list.append(tag_name)
		if add_from_signal:
			line_edit.clear()
		return
	
	# So now we can add it
	
	if Tagger.tag_manager.has_tag(tag_name):
		append_registered_tag(Tagger.tag_manager.get_tag(tag_name))
		item_list.select(item_list.add_item(tag_name, load("res://Textures/valid_tag.png")))
	else:
		append_empty_tag(tag_name)
		item_list.select(item_list.add_item(tag_name, load("res://Textures/generic_tag.png")))
	
	item_list.ensure_current_is_visible()
	full_tag_list.append(tag_name)
	
	if character_bodytypes.has(tag_name):
		body_types_added += 1
	elif character_genders.has(tag_name):
		genders_added += 1
	
	if add_from_signal:
		line_edit.clear()
	
	check_minimum_requirements()
	
	if Tagger.settings.search_suggested:
		tag_queue.append(tag_name)
		start_suggestion_lookup()


func add_suggested_tag(tag_name: String) -> void:
	if suggestion_tags_array.has(tag_name) or tags_inputed.has(tag_name) or implied_tags_array.has(tag_name):
		return
	
	suggestion_tags_array.append(tag_name)
	suggested_list.add_item(tag_name)


func update_parents(tag_resource: Tag) -> void:
	if not tags_inputed.has(tag_resource.tag):
		return
	
	tag_list_generator._dad_queue = [tag_resource]
	tag_list_generator.explore_parents_v2()
	
	implied_species_added += tag_list_generator.types_count["species"]
	implied_genders_added += tag_list_generator.types_count["genders"]
	implied_types_added += tag_list_generator.types_count["body_types"]
	
	for implied_parent in tag_list_generator._kid_return:
		if not implied_tags_array.has(implied_parent) and not full_tag_list.has(implied_parent):
			implied_tags_array.append(implied_parent)
			implied_list.add_item(implied_parent)
			
			if implied_parent in character_genders:
				implied_genders_added += 1
			elif implied_parent in character_bodytypes:
				implied_types_added += 1
	
	if Tagger.settings.load_suggested:
		for suggested_tag in tag_list_generator._offline_suggestions:
			if not suggestion_tags_array.has(suggested_tag):
				suggestion_tags_array.append(suggested_tag)
				suggested_list.add_item(suggested_tag)
	
	tag_list_generator._kid_return.clear()
	tag_list_generator._offline_suggestions.clear()
	tag_list_generator._groped_dads.clear()
	

func update_tag(tag_name: String) -> void:
	if not tags_inputed.has(tag_name):
		pass
	
	var current_index: int = full_tag_list.find(tag_name)
	
	if Tagger.tag_manager.has_tag(tag_name):
		append_registered_tag(Tagger.tag_manager.get_tag(tag_name))
		item_list.set_item_icon(current_index, load("res://Textures/valid_tag.png"))
	else:
		item_list.set_item_icon(current_index, load("res://Textures/generic_tag.png"))
	check_minimum_requirements()
	
	
func remove_tag(item_index: int) -> void: # Connect to itemlist activate
	var tag_name: String = item_list.get_item_text(item_index)
	
	remove_from_category(tags_inputed[tag_name]["category"])
	
	if character_genders.has(tag_name):
		genders_added -= 1
	elif character_bodytypes.has(tag_name):
		body_types_added -= 1

	tags_inputed.erase(tag_name)
	full_tag_list.remove_at(item_index)
	item_list.remove_item(item_index)
	regenerate_parents()
	check_minimum_requirements()


func add_to_category(category_added: Tagger.Categories) -> void:
	if category_added == Tagger.Categories.SPECIES:
		species_added += 1
	elif category_added == Tagger.Categories.CHARACTER:
		character_amounts_added += 1
	check_minimum_requirements()


func remove_from_category(category_added: Tagger.Categories) -> void:
	if category_added == Tagger.Categories.SPECIES:
		species_added -= 1
	elif category_added == Tagger.Categories.CHARACTER:
		character_amounts_added -= 1
	check_minimum_requirements()


func translate_category(e621_post_category: int) -> Tagger.Categories:
	if e621_post_category == e621Tag.Category.ARTIST:
		return Tagger.Categories.ARTIST
	elif e621_post_category == e621Tag.Category.COPYRIGHT:
		return Tagger.Categories.COPYRIGHT
	elif e621_post_category == e621Tag.Category.CHARACTER:
		return Tagger.Categories.CHARACTER
	elif e621_post_category == e621Tag.Category.SPECIES:
		return Tagger.Categories.SPECIES
	else:
		return Tagger.Categories.GENERAL


func check_minimum_requirements() -> void: #Add one call on ready
	var warnings_string: String = ""
	
	if not full_tag_list.has(character_amounts[clampi(character_amounts_added, 0, 4)]):
		warnings_string += "- {0} character tags detected. Recommended tag: \"{1}.\"\n".format(
				[str(character_amounts_added), str(character_amounts[clampi(character_amounts_added, 0, 4)])]
		)
	if body_types_added + implied_types_added == 0 and 0 < character_amounts_added:
		warnings_string += "- No body type specified.\n"
	if genders_added + implied_genders_added == 0 and 0 < character_amounts_added:
		warnings_string += "- No gender tags included.\n"
	if species_added + implied_species_added == 0 and 0 < character_amounts_added:
		warnings_string += "- No species tags added.\n"
	
	if warnings_string.is_empty():
		warning_rect.hide()
		warning_rect.tooltip_text = ""
	else:
		warning_rect.show()
		warning_rect.tooltip_text = warnings_string


func add_from_suggested(item_activated: int) -> void: # Connect to item activated
	var _tag_text = suggested_list.get_item_text(item_activated)
	
	suggested_list.remove_item(item_activated)
	suggestion_tags_array.remove_at(item_activated)
	
	if not full_tag_list.has(_tag_text):
		add_new_tag(_tag_text, false)
	
		if Tagger.settings.search_suggested:
			tag_queue.append(_tag_text)
			start_suggestion_lookup()


func regenerate_parents() -> void:
	implied_tags_array.clear()
	implied_list.clear()

	tag_list_generator._dad_queue.clear()
	
	var parents_array: Array = []
	
	for tag_name in tags_inputed.keys():
		if Tagger.tag_manager.has_tag(tag_name):
			parents_array.append(Tagger.tag_manager.get_tag(tag_name))
	
	tag_list_generator._dad_queue = parents_array.duplicate()
	
	tag_list_generator.explore_parents_v2()
	
	print(tag_list_generator.types_count)
	
	implied_species_added = tag_list_generator.types_count["species"]
	implied_genders_added = tag_list_generator.types_count["genders"]
	implied_types_added = tag_list_generator.types_count["body_types"]

	for imp_tag in tag_list_generator._kid_return:
		if full_tag_list.has(imp_tag) or implied_tags_array.has(imp_tag):
			continue		
		implied_tags_array.append(imp_tag)
		implied_list.add_item(imp_tag)


func clear_all_tags() -> void: # Connect to clear all dropdown menu
	full_tag_list.clear()
	tags_inputed.clear()
	suggestion_tags_array.clear()
	implied_tags_array.clear()
	
	item_list.clear()
	suggested_list.clear()
	implied_list.clear()
	
	final_tag_list_array.clear()
	
	check_minimum_requirements()


func clear_inputted_tags() -> void: # Connect to clear tags button
	full_tag_list.clear()
	implied_tags_array.clear()
	
	item_list.clear()
	implied_list.clear()
	
	final_tag_list_array.clear()
	
	check_minimum_requirements()


func clear_suggestion_tags() -> void: # Connect to clear suggeted button
	suggestion_tags_array.clear()
	suggested_list.clear()


func load_tag_list(tags_to_load: Array, replace_tags: bool) -> void:
	if replace_tags:
		item_list.clear()
		suggested_list.clear()
		implied_list.clear()
		full_tag_list.clear()
		suggestion_tags_array.clear()
		implied_tags_array.clear()
		tags_inputed.clear()
	
	for tag in tags_to_load:
		add_new_tag(Tagger.alias_database.get_alias(tag), false)


# ------------------------------------------------------


func _ready():
	show()
	# Experimental connects
	line_edit.text_submitted.connect(add_new_tag)
	e_621_requester.get_finished.connect(append_online_data)
	suggested_list.item_activated.connect(add_from_suggested)
	item_list.item_activated.connect(remove_tag)
	clear_tags_button.pressed.connect(clear_inputted_tags)
	clear_suggested_button.pressed.connect(clear_suggestion_tags)
	# ---------------------
	
	check_minimum_requirements()
	
	tagger_context_menu.id_pressed.connect(left_click_context_menu_clicked)
	item_list.item_clicked.connect(move_left_context)
	
	$AddAutoComplete/QuickSearch.add_tag_signal.connect(add_new_tag)
	
	add_auto_complete.visible = false
	open_auto_complete_btn.pressed.connect(add_auto_complete.show)
	tagger_menu_bar.set_item_checked(tagger_menu_bar.get_item_index(2), Tagger.settings.search_suggested)
	tagger_menu_bar.set_item_checked(tagger_menu_bar.get_item_index(3), Tagger.settings.load_suggested)
	
	tagger_menu_bar.id_pressed.connect(tagger_menu_pressed)
	

#	clear_suggested_button.pressed.connect(clear_suggested_tags)
#	clear_tags_button.pressed.connect(clear_manual_tags)
#	line_edit.text_submitted.connect(submit_text)
#	item_list.item_activated.connect(remove_item)
#	e_621_requester.get_finished.connect(suggestions_found)
#	suggested_list.item_activated.connect(transfer_suggested)
#	item_list.empty_clicked.connect(item_list.deselect_all) # Might delete
	generate_list.pressed.connect(generate_tag_list)
	copy_to_clipboard.pressed.connect(copy_resut_to_clipboard)
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


func move_left_context(index: int, item_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		context_menu_item_index = index
		tagger_context_menu.position = item_position + Vector2(16, 48)
		
		var tag_text: String = item_list.get_item_text(index)
		
		if Tagger.tag_manager.has_tag(tag_text):
			tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(0), true)
			tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(1), false)
		else:
			tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(0), false)
			tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(1), true)

		tagger_context_menu.show()


func left_click_context_menu_clicked(id_pressed: int) -> void:
	if id_pressed == 0:
		main_application.go_to_create_tag(item_list.get_item_text(context_menu_item_index))
	elif id_pressed == 1:
		main_application.go_to_edit_tag(item_list.get_item_text(context_menu_item_index))
	elif id_pressed == 2:
		remove_tag(context_menu_item_index)


#func _unhandled_key_input(event): # Useless now
#	if event.is_action_pressed("ui_text_delete") and item_list.is_anything_selected():
#		for selected_item in item_list.get_selected_items():
#			item_list.remove_item(selected_item)


func tagger_menu_pressed(option_id: int) -> void:
	var item_index: int = tagger_menu_bar.get_item_index(option_id)
	
	if option_id == 0:
#		clear_tags()
		clear_all_tags()
	elif option_id == 1:
#		clear_suggestion_box()
		clear_suggestion_tags()
	elif option_id == 2:
		tagger_menu_bar.toggle_item_checked(item_index)
		Tagger.settings.search_suggested = tagger_menu_bar.is_item_checked(item_index)
	elif option_id == 3:
		tagger_menu_bar.toggle_item_checked(item_index)
		Tagger.settings.load_suggested = tagger_menu_bar.is_item_checked(tagger_menu_bar.get_item_index(option_id))
	elif option_id == 4:
		conflicting_tags.show()


#func clear_manual_tags() -> void: # TO be replaced by clear_inputted_Tags()
#	_full_tag_list.clear()
#	implied_tags_array.clear()
#	valid_tags.clear()
#	generic_tags.clear()
#
#	item_list.clear()
#	implied_list.clear()
#

#func clear_suggested_tags() -> void: # To be replaced by clear_suggestion_tags
#	suggestion_tags_array.clear()
#	suggested_list.clear()


#func clear_tags() -> void: # To be replaced by clear_all_tags
#	_full_tag_list.clear()
#	implied_tags_array.clear()
#	valid_tags.clear()
#	generic_tags.clear()
#	suggestion_tags_array.clear()
#
#	item_list.clear()
#	implied_list.clear()
#	suggested_list.clear()
#
#	final_tag_list.clear()


func clean_suggestions() -> void:
	for tag in suggestion_tags_array.duplicate():
		if implied_tags_array.has(tag) or full_tag_list.has(tag):
			var _remove_index: int = suggestion_tags_array.find(tag)
			suggestion_tags_array.remove_at(_remove_index)
			suggested_list.remove_item(_remove_index)


#func clear_suggestion_box() -> void: # Duplicate. Remove
#	suggestion_tags_array.clear()
#	suggested_list.clear()


#func remove_item(item_id: int) -> void: # Replaced by remove_tag()
#	var _id_name: String = item_list.get_item_text(item_id)
#
#	if generic_tags.has(_id_name):
#		quick_erase(_id_name, generic_tags)
#	elif valid_tags.has(_id_name):
#		valid_tags.erase(_id_name)
#
#	_full_tag_list.remove_at(item_id)
#	item_list.remove_item(item_id)
#	regenerate_implied()


#func regenerate_implied() -> void: # To be replaced by regenerate_parents()
#	implied_tags_array.clear()
#	implied_list.clear()
#
#	tag_list_generator._dad_queue.clear()
#
#	tag_list_generator._dad_queue = valid_tags.values()
#
#	tag_list_generator.explore_parents()
#
#	for imp_tag in tag_list_generator._kid_return:
#		if _full_tag_list.has(imp_tag) or implied_tags_array.has(imp_tag):
#			continue		
#		implied_tags_array.append(imp_tag)
#		implied_list.add_item(imp_tag)


#func quick_erase(element_to_erase, array_ref: Array) -> void: # No longer needed.
#	if not array_ref.has(element_to_erase):
#		return
#
#	if element_to_erase == array_ref.back():
#		array_ref.erase(element_to_erase)
#		return
#
#	var _index_target = array_ref.find(element_to_erase)
#
#	array_ref[_index_target] = array_ref.back()
#	array_ref.resize(array_ref.size() - 1)


#func add_tag(tag_to_add: String) -> void: # Redundant. Replaced by add_new_tag
#	if _full_tag_list.has(tag_to_add):
#		return
#
#	if Tagger.tag_manager.has_tag(tag_to_add):
#		if not valid_tags.has(tag_to_add):
#			var _tag_loading = Tagger.tag_manager.get_tag(tag_to_add)
#			add_valid_tag(tag_to_add, _tag_loading)
#	else:
#		add_generic_tag(tag_to_add)


#func submit_text(text_to_add: String) -> void:  # Replaced by add_new_tag
#	text_to_add = text_to_add.to_lower().strip_edges()
#	text_to_add = text_to_add.replace("_", " ")
#
#	if text_to_add == "":
#		line_edit.clear()
#		return
#
#	var _target_tag: String = Tagger.alias_database.get_alias(text_to_add)
#
#	if Tagger.settings_lists.invalid_tags.has(_target_tag):
#		add_invalid_tag(_target_tag)
#		line_edit.clear()
#		return
#
#	if _full_tag_list.has(_target_tag):
#		item_list.select(_full_tag_list.find(_target_tag))
#		item_list.ensure_current_is_visible()
#		line_edit.clear()
#		return
#
#	add_tag(_target_tag)
#
#	line_edit.clear()
#
#	if Tagger.settings.search_suggested:
#		tag_queue.append(_target_tag)
#		start_suggestion_lookup()


#func button_press() -> void: # Unused
#	if line_edit.text != "":
#		item_list.add_item(line_edit.text)
#		line_edit.clear()


#func is_tag_added(tag_string: String) -> bool: # Unused
#	tag_string = tag_string.strip_edges().replace("_", " ")
#	return _full_tag_list.has(Tagger.alias_database.get_alias(tag_string))


#func load_tags(tags_to_load: Array, replace_tags: bool) -> void: # To be replaced by load_tag_list
#	if replace_tags:
#		item_list.clear()
#		suggested_list.clear()
#		implied_list.clear()
#
#		_full_tag_list.clear()
#		generic_tags.clear()
#		valid_tags.clear()
#		suggestion_tags_array.clear()
#		implied_tags_array.clear()
#
#	for tag in tags_to_load:
#
#		var _aliased: String = Tagger.alias_database.get_alias(tag)
#
#		if Tagger.tag_manager.has_tag(_aliased):
#
#			var generic_index: int = -1
#
#			if generic_tags.has(_aliased):
#				generic_index = _full_tag_list.find(_aliased)
#				item_list.remove_item(generic_index)
#				generic_tags.erase(_aliased)
#				_full_tag_list.remove_at(generic_index)
#
#			if not _full_tag_list.has(_aliased):
#				add_valid_tag(_aliased, Tagger.tag_manager.get_tag(_aliased), generic_index)
#		else:
#			if not _full_tag_list.has(_aliased):
#				add_generic_tag(_aliased)


func start_suggestion_lookup() -> void:
	if is_searching_tags:
		return
	
	is_searching_tags = true
	search_suggested()


func search_suggested() -> void:
	e_621_requester.match_name.clear()
	e_621_requester.match_name.append(tag_queue.pop_front())
	e_621_requester.get_tags()
	

func suggestions_found(e621_data_array: Array) -> void:
	var e621_tag_data: e621Tag = e621_data_array.front()
	
	for item in e621_tag_data.get_tags_with_strenght():
		if suggestion_tags_array.has(item) or full_tag_list.has(item):
			continue
		
		if not suggestion_tags_array.has(item) and not Tagger.settings_lists.suggestion_blacklist.has(item):
			suggestion_tags_array.append(item)
			suggested_list.add_item(item)
	
	if not tag_queue.is_empty():
		suggestion_timer.start()
	else:
		is_searching_tags = false
	

#func transfer_suggested(item_activated: int) -> void: # Replaced by add_from_suggested
#	var _tag_text = suggested_list.get_item_text(item_activated)
#
#	if _full_tag_list.has(_tag_text):
#		suggested_list.remove_item(item_activated)
#		suggestion_tags_array.erase(_tag_text)
#		return
#
#	if Tagger.tag_manager.has_tag(_tag_text):
#		if not valid_tags.has(_tag_text):
#			var _tag_loading = Tagger.tag_manager.get_tag(_tag_text)
#			if _tag_loading:
#				add_valid_tag(_tag_text, _tag_loading)
#			else:
#				add_generic_tag(_tag_text)
#	else:
#		add_generic_tag(_tag_text)
#
#	if Tagger.settings.search_suggested:
#		tag_queue.append(_tag_text)
#		start_suggestion_lookup()


func generate_tag_list() -> void: # Clean comments
#	tag_list_generator.generate_tag_list(valid_tags.values(), generic_tags)
#	final_tag_list_array = tag_list_generator.get_tag_list().duplicate()
#	final_tag_list.text = tag_list_generator.create_list_from_array(final_tag_list_array)
	tag_list_generator.generate_tag_list_v2(tags_inputed)
	tag_list_generator.__explore_parents_v2()
	final_tag_list_array = tag_list_generator.get_tag_list_v2()
	final_tag_list.text = tag_list_generator.create_list_from_array(final_tag_list_array)
	
	
# Replaced by add_new_tag()
#func add_valid_tag(tag_name: String, tag_data: Tag, add_position: int = -1) -> void:
#	if valid_tags.has(tag_name):
#		return
#
#	if implied_tags_array.has(tag_name):
#		var _index = implied_tags_array.find(tag_name)
#		implied_list.remove_item(_index)
#		implied_tags_array.remove_at(_index)
#
#	if suggestion_tags_array.has(tag_name):
#		var _s_index = suggestion_tags_array.find(tag_name)
#		suggested_list.remove_item(_s_index)
#		suggestion_tags_array.remove_at(_s_index)
#
#	valid_tags[tag_name] = tag_data
#
#	if add_position != -1:
#		_full_tag_list.insert(add_position, tag_name)
#	else:
#		_full_tag_list.append(tag_name)
#
#	tag_list_generator._dad_queue = [tag_data]
#	tag_list_generator.explore_parents()
#
#	for implied_parent in tag_list_generator._kid_return:
#		if not implied_tags_array.has(implied_parent) and not _full_tag_list.has(implied_parent):
#			implied_tags_array.append(implied_parent)
#			implied_list.add_item(implied_parent)
#
#	if Tagger.settings.load_suggested:
#		for suggested_tag in tag_list_generator._offline_suggestions:
#			if not suggestion_tags_array.has(suggested_tag):
#				suggestion_tags_array.append(suggested_tag)
#				suggested_list.add_item(suggested_tag)
#
#	tag_list_generator._kid_return.clear()
#	tag_list_generator._offline_suggestions.clear()
#	tag_list_generator._groped_dads.clear()
#
#	var item_index: int = item_list.add_item(tag_name, load("res://Textures/valid_tag.png"))
#
#	if add_position != -1:
#		item_list.move_item(item_index, add_position)
#
#	item_list.select(item_index)
#	item_list.ensure_current_is_visible()


# Replaced by add_new_tag()
#func add_generic_tag(tag_name: String) -> void:
#	if generic_tags.has(tag_name):
#		return
#
#
#	if implied_tags_array.has(tag_name):
#		var _index = implied_tags_array.find(tag_name)
#		implied_list.remove_item(_index)
#		implied_tags_array.remove_at(_index)
#
#	if suggestion_tags_array.has(tag_name):
#		var _s_index = suggestion_tags_array.find(tag_name)
#		suggested_list.remove_item(_s_index)
#		suggestion_tags_array.remove_at(_s_index)
#
#	generic_tags.append(tag_name)
#	_full_tag_list.append(tag_name)
#	item_list.select(item_list.add_item(tag_name, load("res://Textures/generic_tag.png")))
#	item_list.ensure_current_is_visible()


# Replaced by add_new_tag()
#func add_invalid_tag(inv_tag_name: String) -> void:
#	_full_tag_list.append(inv_tag_name)
#	item_list.select(item_list.add_item(inv_tag_name, load("res://Textures/bad.png")))
#	item_list.ensure_current_is_visible()


func copy_resut_to_clipboard() -> void:
	if final_tag_list.text == "":
		return
	
	DisplayServer.clipboard_set(final_tag_list.text)
	copy_to_clipboard.text = "Copied!"
	copy_timer.start()


func on_copy_timer_timeout() -> void:
	copy_to_clipboard.text = "Copy to Clipboard"

