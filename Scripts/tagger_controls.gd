extends Control
class_name TaggerInstance

@onready var line_edit: LineEdit = $LineEdit
@onready var item_list: ItemList = $CurrentTags/ItemList
@onready var suggested_list: ItemList = $Suggested/SuggestedList
@onready var tag_list_generator: TagListGenerator = $TagListGenerator
@onready var generate_list: Button = $GenerateList
@onready var final_tag_list: TextEdit = $FinalList/FinalTagList
@onready var implied_list: ItemList = $"Implied Tags/ImpliedList"
@onready var copy_to_clipboard: Button = $CopyToClipboard
@onready var clean_suggestions_button: Button = $CleanSuggestionsButton
@onready var add_auto_complete: Control = $AddAutoComplete
@onready var open_auto_complete_btn: Button = $OpenAutoCompleteBTN

@onready var conflicting_tags: Control = $ConflictingTags

@onready var clear_tags_button: Button = $ClearTagsButton
@onready var clear_suggested_button: Button = $ClearSuggestedButton
@onready var tagger_context_menu: PopupMenu = $TaggerContextMenu
@onready var warning_rect: TextureRect = $WarningRect
@onready var suggestion_timer: Timer = $SuggestionTimer
@onready var copy_timer: Timer = $CopyTimer
@onready var quick_search = $AddAutoComplete/QuickSearch

var main_application
var tagger_menu_bar: PopupMenu
var tag_holder
var instance_name: String
var tag_queue: Array[String] = []
var is_searching_tags: bool = false

var suggestion_tags_array: Array[String] = []
var implied_tags_array: Array[String] = []

var final_tag_list_array: Array[String] = []


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

var tags_inputed: Dictionary = {} 
var full_tag_list: Array[String] = [] 

var species_added: int = 0
var genders_added: int = 0
var character_amounts_added: int = 0
var body_types_added: int = 0

var character_count_added: int = 0
var zero_pictured: bool = false


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


func append_prefilled_tag(tag_name: String, tag_dict: Dictionary) -> void:
	if tag_name.is_empty() or tag_dict.is_empty():
		return

	if Tagger.settings_lists.invalid_tags.has(tag_name):
		var index: int = item_list.add_item(tag_name, load("res://Textures/bad.png"))
		item_list.select(index)
		item_list.set_item_tooltip(index, "This tag is an invalid tag")
		item_list.set_item_custom_fg_color(index, Color.html(Tagger.settings.category_color_code["INVALID"]))
		full_tag_list.append(tag_name)
		return
		
	if tags_inputed.has(tag_name):
		tags_inputed[tag_name]["id"] = tag_dict["id"]
		tags_inputed[tag_name]["post_count"] = tag_dict["post_count"]
		tags_inputed[tag_name]["related_tags"] = tag_dict["related_tags"]
		tags_inputed[tag_name]["is_locked"] = tag_dict["is_locked"]
	else:
		if tag_name == "zero pictured":
			zero_pictured = true
		tags_inputed[tag_name] = tag_dict
		full_tag_list.append(tag_name)
		add_to_category(tag_dict["category"])
		
		var add_index: int = 0
		
		if Tagger.tag_manager.has_tag(tag_name):
			add_index = item_list.add_item(tag_name, load("res://Textures/valid_tag.png"))
		else:
			add_index = item_list.add_item(tag_name, load("res://Textures/generic_tag.png"))
		
		item_list.select(add_index)
		item_list.set_item_custom_fg_color(
					add_index,
					Color.html(Tagger.settings.category_color_code[Tagger.Categories.keys()[tag_dict["category"]]]))
		
		if character_bodytypes.has(tag_name):
			body_types_added += 1
		elif character_genders.has(tag_name):
			genders_added += 1
		elif character_amounts.has(tag_name):
			character_count_added += 1
	
		if Tagger.settings.search_suggested:
#			tag_queue.append(tag_name)
#			start_suggestion_lookup()
			tag_holder.add_to_search_queue({tag_name: self})
	
	item_list.ensure_current_is_visible()
	
	for related_tag in tag_dict["related_tags"]:
		add_suggested_tag(related_tag)
	for suggested_tag in tag_dict["suggested_tags"]:
		add_suggested_tag(suggested_tag)
	
	check_minimum_requirements()


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
	
	if Tagger.settings.load_suggested:
		for suggestion in tag_resource.suggestions:
			add_suggested_tag(suggestion)
	
	if Tagger.settings.search_suggested:
		for related_tag in tags_inputed[tag_resource.tag]["related_tags"]:
			add_suggested_tag(related_tag)
	
	add_to_category(tag_resource.category)


func api_response(dictionary_response: Dictionary) -> void:
	var array_with_resource = dictionary_response["response"]
	tag_queue.erase(dictionary_response["tags"].front())
	
	if array_with_resource.is_empty():
		return
	
	var tag_resource: e621Tag = array_with_resource.front()
	if tags_inputed.has(tag_resource.tag_name):
		tags_inputed[tag_resource.tag_name]["id"] = tag_resource.id
		tags_inputed[tag_resource.tag_name]["post_count"] = tag_resource.post_count
		tags_inputed[tag_resource.tag_name]["related_tags"] = tag_resource.get_tags_with_strength()
		tags_inputed[tag_resource.tag_name]["is_locked"] = tag_resource.is_locked
		
		if tags_inputed[tag_resource.tag_name]["category"] == Tagger.Categories.GENERAL and translate_category(tag_resource.category) != Tagger.Categories.GENERAL:
			tags_inputed[tag_resource.tag_name]["category"] = translate_category(tag_resource.category)
			add_to_category(translate_category(tag_resource.category))
		for tag in tag_resource.get_tags_with_strength():
			add_suggested_tag(tag)


func add_new_tag(tag_name: String, add_from_signal: bool = true, search_online: bool = true, suggested_tags: Array = [], tag_category := Tagger.Categories.GENERAL) -> void: # Connect line submit here
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
		var invalid_index:int = item_list.add_item(tag_name, load("res://Textures/bad.png"))
		full_tag_list.append(tag_name)
		item_list.set_item_custom_fg_color(invalid_index, Color.html(Tagger.settings.category_color_code["INVALID"]))
		item_list.set_item_tooltip(invalid_index, "Invalid tag")
		item_list.select(invalid_index)
		item_list.ensure_current_is_visible()
		if add_from_signal:
			line_edit.clear()
		return
	
	# So now we can add it
	
	if tag_name == "zero pictured":
		zero_pictured = true
	
	if Tagger.tag_manager.has_tag(tag_name):
		var tag_load: Tag = Tagger.tag_manager.get_tag(tag_name)
		append_registered_tag(tag_load)
		
		var add_index: int = item_list.add_item(tag_name, load("res://Textures/valid_tag.png"))
		if Color.html_is_valid(Tagger.settings.category_color_code[Tagger.Categories.keys()[tag_load.category]]):
			item_list.set_item_custom_fg_color(
					add_index,
					Color.html(Tagger.settings.category_color_code[Tagger.Categories.keys()[tag_load.category]]))
		
		if not tag_load.tooltip.is_empty():
			item_list.set_item_tooltip(add_index, tag_load.tooltip)
		
		item_list.select(add_index)
	else:
		append_empty_tag(tag_name)
		
		if tag_category != Tagger.Categories.GENERAL:
			tags_inputed[tag_name]["category"] = tag_category
			add_to_category(tag_category)
		var add_index: int = item_list.add_item(tag_name, load("res://Textures/generic_tag.png"))
		item_list.set_item_custom_fg_color(add_index, Color.html("cccccc"))
		item_list.select(add_index)
	
	if implied_tags_array.has(tag_name):
		implied_list.remove_item(implied_tags_array.find(tag_name))
		implied_tags_array.erase(tag_name)
	
	for suggested_tag in suggested_tags:
		add_suggested_tag(suggested_tag)
	
	item_list.ensure_current_is_visible()
	full_tag_list.append(tag_name)
	
	if character_bodytypes.has(tag_name):
		body_types_added += 1
	elif character_genders.has(tag_name):
		genders_added += 1
	elif character_amounts.has(tag_name):
			character_count_added += 1
	
	if add_from_signal:
		line_edit.clear()
	
	check_minimum_requirements()
	
	if Tagger.settings.search_suggested and search_online:
		tag_queue.append(tag_name)
		tag_holder.add_to_api_queue(tag_name, 1, self)


func close_instance() -> void:
	for pending_tag in tag_queue:
		tag_holder.remove_from_api_queue(pending_tag, self, 1)
	quick_search.close_instance()


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
	
	if tags_inputed.has(tag_name):
		var current_index: int = full_tag_list.find(tag_name)
		
		if Tagger.tag_manager.has_tag(tag_name):
			var tag_load: Tag = Tagger.tag_manager.get_tag(tag_name)
			append_registered_tag(tag_load)
			item_list.set_item_icon(current_index, load("res://Textures/valid_tag.png"))
			if not tag_load.tooltip.is_empty():
				item_list.set_item_tooltip(current_index, tag_load.tooltip)
		else:
			item_list.set_item_icon(current_index, load("res://Textures/generic_tag.png"))

	if implied_tags_array.has(tag_name):
		regenerate_parents()
	
	check_minimum_requirements()


func remove_tag(item_index: int) -> void: # Connect to itemlist activate
	var tag_name: String = item_list.get_item_text(item_index)
	
	if tag_name == "zero pictured":
		zero_pictured = false
	
	if not tags_inputed.has(tag_name):
		full_tag_list.remove_at(item_index)
		item_list.remove_item(item_index)
		return
	
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
	
	tag_holder.remove_from_api_queue(tag_name, self, 1)


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
	var suggestions_string: String = ""
	
	if not full_tag_list.has(character_amounts[clampi(character_amounts_added, 0, 4)]):
		suggestions_string = "- {0} character tags detected. Recommended tag: \"{1}.\"\n".format(
				[str(character_amounts_added), str(character_amounts[clampi(character_amounts_added, 0, 4)])]
		)
	if character_count_added == 0:
		warnings_string += "- No character amount specified.\n"
	if body_types_added + implied_types_added == 0 and not zero_pictured:
		warnings_string += "- No body type specified.\n"
	if genders_added + implied_genders_added == 0 and not zero_pictured:
		warnings_string += "- No gender tags included.\n"
	if species_added + implied_species_added == 0 and not zero_pictured:
		warnings_string += "- No species tags added.\n"
	
	if warnings_string.is_empty() and suggestions_string.is_empty():
		warning_rect.hide()
		warning_rect.tooltip_text = ""
	else:
		if not warnings_string.is_empty():
			warning_rect.texture = load("res://Textures/WarningIcon.svg")
		else:
			warning_rect.texture = load("res://Textures/InfoIcon.svg")
		warning_rect.show()
		warning_rect.tooltip_text = suggestions_string + warnings_string


func add_from_suggested(item_activated: int) -> void: # Connect to item activated
	var _tag_text = suggested_list.get_item_text(item_activated)
	
	suggested_list.remove_item(item_activated)
	suggestion_tags_array.remove_at(item_activated)
	
	if not full_tag_list.has(_tag_text):
		add_new_tag(_tag_text, false)
	
		if Tagger.settings.search_suggested:
#			tag_queue.append(_tag_text)
#			start_suggestion_lookup()
			tag_holder.add_to_search_queue(_tag_text)


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
	
	implied_species_added = tag_list_generator.types_count["species"]
	implied_genders_added = tag_list_generator.types_count["genders"]
	implied_types_added = tag_list_generator.types_count["body_types"]
	
	for imp_tag in tag_list_generator._kid_return:
		if full_tag_list.has(imp_tag) or implied_tags_array.has(imp_tag):
			continue		
		implied_tags_array.append(imp_tag)
		implied_list.add_item(imp_tag)


func clear_all_tags() -> void: # Connect to clear all dropdown menu
	if tag_holder.active_instance != instance_name:
		return
	
	full_tag_list.clear()
	tags_inputed.clear()
	suggestion_tags_array.clear()
	implied_tags_array.clear()
	
	item_list.clear()
	suggested_list.clear()
	implied_list.clear()
	
	final_tag_list_array.clear()
	final_tag_list.clear()
	
	species_added = 0
	genders_added = 0
	character_amounts_added = 0
	body_types_added = 0
	zero_pictured = false
	character_count_added = 0

	implied_species_added = 0
	implied_genders_added = 0
	implied_types_added = 0
	
	check_minimum_requirements()


func clear_inputted_tags() -> void: # Connect to clear tags button
	tags_inputed.clear()
	full_tag_list.clear()
	implied_tags_array.clear()
	
	item_list.clear()
	implied_list.clear()
	
	final_tag_list_array.clear()
	final_tag_list.clear()
	
	species_added = 0
	genders_added = 0
	character_amounts_added = 0
	body_types_added = 0
	zero_pictured = false
	character_count_added = 0

	implied_species_added = 0
	implied_genders_added = 0
	implied_types_added = 0
	
	check_minimum_requirements()


func clear_suggestion_tags() -> void: # Connect to clear suggeted button
	if tag_holder.active_instance != instance_name:
		return
	
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

func disconnect_and_free() -> void:
	close_instance()
	tagger_menu_bar.id_pressed.disconnect(tagger_menu_pressed)
	tagger_menu_bar = null
	main_application = null
	tag_holder = null
	self.queue_free()


func _ready():
	# Experimental connects
	line_edit.text_submitted.connect(add_new_tag)
	suggested_list.item_activated.connect(add_from_suggested)
	item_list.item_activated.connect(remove_tag)
	clear_tags_button.pressed.connect(clear_inputted_tags)
	clear_suggested_button.pressed.connect(clear_suggestion_tags)
	# ---------------------
	
	check_minimum_requirements()
	
	tagger_context_menu.id_pressed.connect(left_click_context_menu_clicked)
	item_list.item_clicked.connect(move_left_context)
	
	$AddAutoComplete/QuickSearch.add_tag_signal.connect(append_prefilled_tag)
	
	add_auto_complete.visible = false
	open_auto_complete_btn.pressed.connect(add_auto_complete.show)
	tagger_menu_bar.id_pressed.connect(tagger_menu_pressed)
	
	generate_list.pressed.connect(generate_tag_list)
	copy_to_clipboard.pressed.connect(copy_resut_to_clipboard)
	clean_suggestions_button.pressed.connect(clean_suggestions)
	
#	suggestion_timer.timeout.connect(search_suggested)
	
	copy_timer.timeout.connect(on_copy_timer_timeout)


func move_left_context(index: int, item_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		context_menu_item_index = index
		tagger_context_menu.position = item_position + Vector2(16, 48)
		
		var tag_text: String = item_list.get_item_text(index)
		
		if Tagger.tag_manager.has_tag(tag_text):
			tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(0), true)
			tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(1), false)
			tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(3), false)
		else:
			tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(0), false)
			tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(1), true)
			tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(3), true)
		tagger_context_menu.show()


func left_click_context_menu_clicked(id_pressed: int) -> void:
	if id_pressed == 0:
		var tag_name = item_list.get_item_text(context_menu_item_index)
		main_application.go_to_create_tag(tag_name, tags_inputed[tag_name]["parents"], tags_inputed[tag_name]["suggested_tags"] + tags_inputed[tag_name]["related_tags"], tags_inputed[tag_name]["category"])
	elif id_pressed == 1:
		main_application.go_to_edit_tag(item_list.get_item_text(context_menu_item_index))
	elif id_pressed == 2:
		remove_tag(context_menu_item_index)
	elif id_pressed == 3:
		main_application.go_to_wiki(item_list.get_item_text(context_menu_item_index))


func sort_tags_by_category() -> void:
	if tag_holder.active_instance != instance_name:
		return
	
	if full_tag_list.size() < 2:
		return
	
	var final_array: Array = []
	var sorting_array: Array = []
	var current_tags: Dictionary = tags_inputed.duplicate()
	
	var order_array: Array = [
		Tagger.Categories.ARTIST,
		Tagger.Categories.COPYRIGHT,
		Tagger.Categories.CHARACTER,
		Tagger.Categories.SPECIES,
	]
	
	for category_lookup in order_array:
		for tag in current_tags.keys():
			if current_tags[tag]["category"] == category_lookup:
				sorting_array.append(tag)
				current_tags.erase(tag)
		sorting_array.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
		final_array.append_array(sorting_array)
		sorting_array.clear()
	
	sorting_array = current_tags.keys()
	sorting_array.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	final_array.append_array(sorting_array)
	
	clear_inputted_tags()
	
	for item in final_array:
		add_new_tag(item)


func tagger_menu_pressed(option_id: int) -> void:
	if option_id == 0:
		clear_all_tags()
	elif option_id == 1:
		clear_suggestion_tags()
	elif option_id == 4:
		show_conflicting_tags()
	elif option_id == 8:
		sort_tags_by_category()


func show_conflicting_tags() -> void:
	if tag_holder.active_instance != instance_name:
		return
	
	conflicting_tags.show()


func clean_suggestions() -> void:
	for tag in suggestion_tags_array.duplicate():
		if implied_tags_array.has(tag) or full_tag_list.has(tag):
			var _remove_index: int = suggestion_tags_array.find(tag)
			suggestion_tags_array.remove_at(_remove_index)
			suggested_list.remove_item(_remove_index)


func generate_tag_list() -> void:
	tag_list_generator.generate_tag_list_v2(tags_inputed)
	tag_list_generator.__explore_parents_v2()
	final_tag_list_array = tag_list_generator.get_tag_list_v2()
	final_tag_list.text = tag_list_generator.create_list_from_array(
			final_tag_list_array)


func copy_resut_to_clipboard() -> void:
	if final_tag_list.text == "":
		return
	
	DisplayServer.clipboard_set(final_tag_list.text)
	copy_to_clipboard.text = "Copied!"
	copy_timer.start()


func on_copy_timer_timeout() -> void:
	copy_to_clipboard.text = "Copy to Clipboard"

