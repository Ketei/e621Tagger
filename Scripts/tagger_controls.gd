extends Control
class_name TaggerInstance


const valid_fixes: Array[String] = ["*", "|", "#"]

@onready var line_edit: LineEdit = $HBoxContainer/InputTags/HBoxContainer/LineEdit
@onready var added_tag_list: ItemList = $HBoxContainer/InputTags/ItemList
@onready var suggested_list: ItemList = $HBoxContainer/SuggestedImpliedTags/HBoxContainer/SuggestedTags/SuggestedList
@onready var tag_list_generator: TagListGenerator = $TagListGenerator
@onready var generate_list: Button = $HBoxContainer/FinalTags/HBoxContainer/GenerateList
@onready var final_tag_list: TextEdit = $HBoxContainer/FinalTags/FinalTagList
@onready var copy_to_clipboard: Button = $HBoxContainer/FinalTags/HBoxContainer/ExportsVBox/CopyToClipboard
@onready var add_auto_complete: Control = $AddAutoComplete
@onready var open_auto_complete_btn: Button = $HBoxContainer/InputTags/HBoxContainer/OpenAutoCompleteBTN
@onready var special_suggestions_item_list: ItemList = $HBoxContainer/SuggestedImpliedTags/HBoxContainer/SuggestedTags/SpecialSuggestionsItemList

@onready var conflicting_tags: Control = $ConflictingTags

@onready var clear_tags_button: Button = $HBoxContainer/InputTags/ClearTagsButton
@onready var clear_suggested_button: Button = $HBoxContainer/SuggestedImpliedTags/HBoxContainer/SuggestedTags/HBoxContainer/ClearSuggestedButton
@onready var tagger_context_menu: PopupMenu = $TaggerContextMenu
@onready var copy_timer: Timer = $CopyTimer
@onready var quick_search = $AddAutoComplete/QuickSearch
@onready var export_tags_button: Button = $HBoxContainer/FinalTags/HBoxContainer/ExportsVBox/ExportTagsButton
@onready var tag_file_dialog: TagFileDialog = $TagFileDialog
@onready var available_sites:OptionButton = $HBoxContainer/FinalTags/Platform/AvailableSites
@onready var add_custom_tag: AutofillOptionTag = $AddSuggestedSpecial/CenterContainer/AddCustomTag
@onready var add_suggested_special = $AddSuggestedSpecial
@onready var weezard = $Weezard
@onready var tag_wizard: TagWizard = $Weezard/CenterContainer/TagWizard
@onready var or_adder = $OrAdder
@onready var suggestion_or_adder: SuggestionOrAdder = $OrAdder/CenterContainer/SuggestionOrAdder
@onready var spinbox_adder = $SpinboxAdder
@onready var number_tag_tool: NumberTagTool = $SpinboxAdder/CenterContainer/NumerTag
@onready var clear_special_button: Button = $HBoxContainer/SuggestedImpliedTags/HBoxContainer/SuggestedTags/SpecialLabelContainer/ClearSpecialButton

@onready var set_as_tag = $SetAsTag
@onready var template_loader = $TemplateLoader
@onready var prompt_tag_window = $PromptTagAdd
@onready var special_add: PromptAddTag = $PromptTagAdd/CenterContainer/SpecialAdd

var main_application
var tagger_menu_bar: PopupMenu
var tag_holder
var instance_name: String
var tag_queue: Array[String] = []
var is_searching_tags: bool = false

var final_tag_list_array: Array[String] = []

var context_tag: String = ""
var context_menu_item_index: int = -1
var list_called: ItemList = null
var called_index: int = 0


func _ready():
	available_sites.select(Tagger.available_sites.find(Tagger.site_settings.default_site))
	available_sites.site_selected.connect(change_platform)
	line_edit.text_submitted.connect(add_simple_tag)
	suggested_list.item_activated.connect(add_from_suggested.bind(suggested_list))
	special_suggestions_item_list.item_activated.connect(add_from_suggested.bind(special_suggestions_item_list))
	added_tag_list.item_activated.connect(remove_tag_simple)
	clear_tags_button.pressed.connect(clear_inputted_tags)
	clear_suggested_button.pressed.connect(clear_suggestion_tags)
	export_tags_button.pressed.connect(open_export_dialog)
	clear_special_button.pressed.connect(clear_special_tags)
	template_loader.template_selected.connect(load_tags_from_template)

	tagger_context_menu.id_pressed.connect(left_click_context_menu_clicked)
	
	$AddAutoComplete/QuickSearch.add_tag_signal.connect(legacy_add_from_quicksearch)
	
	add_auto_complete.visible = false
	open_auto_complete_btn.pressed.connect(add_auto_complete.show)
	tagger_menu_bar.id_pressed.connect(tagger_menu_pressed)
	
	generate_list.pressed.connect(generate_tag_list)
	copy_to_clipboard.pressed.connect(copy_resut_to_clipboard)
	
	copy_timer.timeout.connect(on_copy_timer_timeout)
	added_tag_list.open_context_clicked.connect(open_context_menu)
	suggested_list.open_context_clicked.connect(open_context_menu)
	special_suggestions_item_list.open_context_clicked.connect(open_context_menu)


func is_any_window_open() -> bool:
	var is_anything_open: bool = add_auto_complete.visible or\
			conflicting_tags.visible or\
			add_suggested_special.visible or\
			or_adder.visible or\
			spinbox_adder.visible or\
			weezard.visible or\
			set_as_tag.visible or\
			template_loader.visible or\
			prompt_tag_window.visible
	return is_anything_open


func open_template_loader() -> void:
	if tag_holder.active_instance != instance_name:
		return
	template_loader.load_templates()
	template_loader.show()


func load_tags_from_template(_temp_name: String, tag_pcksarray: PackedStringArray, sugs_pcksarray: PackedStringArray) -> void:
	for tag in tag_pcksarray:
		add_simple_tag(tag, false)
	for sug in sugs_pcksarray:
		add_suggested_tag_simple(sug)
	template_loader.hide()


func clear_special_tags() -> void:
	special_suggestions_item_list.clear()


func api_response(dictionary_response: Dictionary) -> void:
	var array_with_resource = dictionary_response["response"]
	tag_queue.erase(dictionary_response["tags"].front())
	
	if array_with_resource.is_empty():
		return
	
	var tag_resource: e621Tag = array_with_resource.front()
	for tag in tag_resource.get_tags_with_strength():
		#add_suggested_tag(tag)
		add_suggested_tag_simple(tag)


func legacy_add_from_quicksearch(tag_name: String, _tag_data):
	add_simple_tag(tag_name)


func add_simple_tag(tag_name: String, focus_on_add: bool = true) -> int:
	line_edit.clear()
	var prefix: String = ""
	var item_index: int = -1
	var _in_parents: bool = false
	
	for compare_fix in Tagger.settings_lists.sorted_shortcuts:
		if tag_name.begins_with(compare_fix):
			prefix = compare_fix
			tag_name = tag_name.trim_prefix(prefix)
			break
	
	if tag_name.strip_edges().is_empty():
		return item_index
	
	if not prefix.is_empty():
		var tag_array: Array = tag_name.split(",", false)
		var preformat_tag: String = Tagger.settings_lists.shortcuts[prefix].replace("%", "{0}")
		tag_name = preformat_tag.format(tag_array)
	
	tag_name = Tagger.alias_database.get_alias(tag_name)
	
	# Check if it exists.
	for tag_item in range(added_tag_list.item_count):
		if added_tag_list.get_item_text(tag_item) == tag_name:
			added_tag_list.select(tag_item)
			added_tag_list.ensure_current_is_visible()
			return tag_item
	# Check if it exists in suggestions. 
	for sugg_id in range(suggested_list.item_count):
		if suggested_list.get_item_text(sugg_id) == tag_name:
			suggested_list.remove_item(sugg_id)
			break
	# Check if invalid
	if Tagger.settings_lists.invalid_tags.has(tag_name): # Check if invalid
		item_index = added_tag_list.add_item(tag_name, load("res://Textures/bad.png"))
		added_tag_list.set_item_custom_fg_color(item_index, Color.html(Tagger.settings.category_color_code["INVALID"]))
		added_tag_list.set_item_tooltip(item_index, "Invalid tag")
		added_tag_list.set_item_metadata(item_index,
			{
				"id": -1,
				"priority": -100,
				"parents": PackedStringArray(),
				"conflicts": PackedStringArray(),
				"post_count": -1,
				"related_tags": PackedStringArray(),
				"suggested_tags": PackedStringArray(),
				"category": Tagger.Categories.GENERAL,
				"is_locked": false,
				"is_registered": false
			})
	else:
		if Tagger.tag_manager.has_tag(tag_name):
			var tag: Tag = Tagger.tag_manager.get_tag(tag_name)
			item_index = added_tag_list.add_item(tag_name, load("res://Textures/valid_tag.png"))
			added_tag_list.set_item_metadata(
					item_index,
					Tagger.tag_manager.get_tag_metadata(tag_name))
			var tag_metadata: Dictionary = added_tag_list.get_item_metadata(item_index)
			var html_code: String = Tagger.settings.category_color_code[Tagger.Categories.keys()[tag_metadata["category"]]]
			added_tag_list.set_item_custom_fg_color(
				item_index,
				Color.html(html_code))
			added_tag_list.set_item_tooltip(
					item_index,
					tag.tooltip)
			
			if Tagger.settings.load_suggested:
				for suggestion in tag.suggestions:
					add_suggested_tag_simple(suggestion)
				for parent_suggest in get_suggestions(get_parents(tag_name)):
					add_suggested_tag_simple(parent_suggest)
		else:
			item_index = added_tag_list.add_item(tag_name, load("res://Textures/generic_tag.png"))
			added_tag_list.set_item_metadata(
					item_index,
					Tagger.tag_manager.get_empty_metadata())
	#update_parents_simple(added_tag_list.get_item_metadata(item_index)["parents"])
	if focus_on_add:
		added_tag_list.select(item_index)
		added_tag_list.ensure_current_is_visible()
	
	if Tagger.settings.search_suggested:
		tag_queue.append(tag_name)
		tag_holder.add_to_api_queue(tag_name, 1, self)
	
	return item_index


func get_parents(tag_name: String) -> Array[String]:
	var parents: Array[String] = []
	
	var explored_parents: Array[String] = []
	var unexplored_parents: Array = []
	
	if not Tagger.tag_manager.has_tag(tag_name):
		return parents
	
	var tag: Tag = Tagger.tag_manager.get_tag(tag_name)
	unexplored_parents.append_array(tag.parents)
	
	while not unexplored_parents.is_empty():
		var tag_text: String = unexplored_parents.pop_front()
		
		if not parents.has(tag_text):
			parents.append(tag_text)
		if not explored_parents.has(tag_text):
			explored_parents.append(tag_text)
		
		if Tagger.tag_manager.has_tag(tag_text):
			var new_parent: Tag = Tagger.tag_manager.get_tag(tag_text)
			for parent in new_parent.parents:
				if explored_parents.has(parent) or unexplored_parents.has(parent):
					continue
				unexplored_parents.append(parent)
	
	return parents
			

func get_suggestions(parent_tags: Array[String]) -> Array[String]:
	var return_suggestions: Array[String] = []
	
	for parent in parent_tags:
		if not Tagger.tag_manager.has_tag(parent):
			continue
		
		var tag_load: Tag = Tagger.tag_manager.get_tag(parent)
		for sug_tag in tag_load.suggestions:
			if not return_suggestions.has(sug_tag):
				return_suggestions.append(sug_tag)
	
	return return_suggestions
			


func close_instance() -> void:
	for pending_tag in tag_queue:
		tag_holder.remove_from_api_queue(pending_tag, self, 1)
	quick_search.close_instance()


#func add_suggested_tag(tag_name: String) -> void:
	#var is_prefixed: bool = false
	#if valid_fixes.has(tag_name.left(1)) or valid_fixes.has(tag_name.right(1)):
		#is_prefixed = true
	#
	#var suggested_pos: int = 0
	#
	#if not is_prefixed:
		#if suggestion_tags_array.has(tag_name) or tags_inputed.has(tag_name) or implied_tags_array.has(tag_name):
			#return
		#suggested_pos = suggested_list.add_item(tag_name)
		#suggestion_tags_array.append(tag_name)
		#
		#if Tagger.tag_manager.has_tag(tag_name):
			#suggested_list.set_item_tooltip(
				#suggested_pos,
				#Tagger.tag_manager.get_tag(tag_name).tooltip)
			#
	#else:
		#if special_suggestions.has(tag_name):
			#return
		#
		#suggested_pos = special_suggestions_item_list.add_item(tag_name)
		#special_suggestions.append(tag_name)


func add_suggested_tag_simple(tag_name: String) -> void:
	var use_prefix: bool = false
	
	if valid_fixes.has(tag_name.left(1)) or valid_fixes.has(tag_name.right(1)):
		use_prefix = true

	var suggested_pos: int = 0
	
	if not use_prefix:
		for tag in range(added_tag_list.item_count):
			if added_tag_list.get_item_text(tag) == tag_name:
				return
		
		for tag_id in range(suggested_list.item_count):
			if suggested_list.get_item_text(tag_id) == tag_name:
				return
	
		suggested_pos = suggested_list.add_item(tag_name)
		
		if Tagger.tag_manager.has_tag(tag_name):
			suggested_list.set_item_tooltip(
				suggested_pos,
				Tagger.tag_manager.get_tag(tag_name).tooltip)
			
	else:
		for sp_id in range(special_suggestions_item_list.item_count):
			if special_suggestions_item_list.get_item_text(sp_id) == tag_name:
				return
		
		suggested_pos = special_suggestions_item_list.add_item(tag_name)


#func update_parents(tag_resource: Tag, add_suggestions: bool = true) -> void:
	#if not tags_inputed.has(tag_resource.tag):
		#return
	#
	#tag_list_generator._dad_queue = [tag_resource]
	#tag_list_generator.explore_parents_v2()
	#
	#implied_species_added += tag_list_generator.types_count["species"]
	#implied_genders_added += tag_list_generator.types_count["genders"]
	#implied_types_added += tag_list_generator.types_count["body_types"]
	#
	#for implied_parent in tag_list_generator._kid_return:
		#if not implied_tags_array.has(implied_parent) and not full_tag_list.has(implied_parent):
			#implied_tags_array.append(implied_parent)
			#implied_list.add_item(implied_parent)
			#
			#if implied_parent in character_genders:
				#implied_genders_added += 1
			#elif implied_parent in character_bodytypes:
				#implied_types_added += 1
	#
	#if Tagger.settings.load_suggested and add_suggestions:
		#for suggested_tag in tag_list_generator._offline_suggestions:
			#if not suggestion_tags_array.has(suggested_tag):
				#add_suggested_tag(suggested_tag)
	#
	#tag_list_generator._kid_return.clear()
	#tag_list_generator._offline_suggestions.clear()
	#tag_list_generator._groped_dads.clear()
#
#
#func update_parents_simple(parent_tags: Array) -> void:
	#if parent_tags.is_empty():
		#return
	#
	#var existing: Array[String] = []
	#var suggestions: Array[String] = []
	#
	#for tag_id in range(added_tag_list.item_count):
		#existing.append(added_tag_list.get_item_text(tag_id)) 
	#
	#for dad_id in range(implied_list.item_count):
		#existing.append(implied_list.get_item_text(dad_id))
	#
	#for sug_id in range(suggested_list.item_count):
		#suggestions.append(suggested_list.get_item_text(sug_id))
	#
	#tag_list_generator._dad_queue = parent_tags
	#tag_list_generator.explore_parents_v3()
#
	#for implied_parent in tag_list_generator._kid_return:
		#if not existing.has(implied_parent):
			#implied_list.add_item(implied_parent)
		#
			#if implied_parent in character_genders:
				#implied_genders_added += 1
			#elif implied_parent in character_bodytypes:
				#implied_types_added += 1
	#
	#if Tagger.settings.load_suggested:
		#for suggested_tag in tag_list_generator._offline_suggestions:
			#if not suggestions.has(suggested_tag):
				#add_suggested_tag(suggested_tag)
	#
	#tag_list_generator._kid_return.clear()
	#tag_list_generator._offline_suggestions.clear()
	#tag_list_generator._groped_dads.clear()


func update_tag(tag_name: String) -> void:
	for added_index in range(added_tag_list.item_count):
		if added_tag_list.get_item_text(added_index) == tag_name:
			if Tagger.tag_manager.has_tag(tag_name):
				added_tag_list.set_item_metadata(
						added_index,
						Tagger.tag_manager.get_tag_metadata(tag_name))
				added_tag_list.set_item_icon(
						added_index,
						load("res://Textures/valid_tag.png"))
			else:
				added_tag_list.set_item_metadata(
						added_index,
						Tagger.tag_manager.get_empty_metadata())
				added_tag_list.set_item_icon(
						added_index,
						load("res://Textures/generic_tag.png"))
			break


#func remove_tag(item_index: int) -> void: # Connect to itemlist activate
	#var tag_name: String = added_tag_list.get_item_text(item_index)
	#
	#if tag_name == "zero pictured":
		#zero_pictured = false
	#
	#if not tags_inputed.has(tag_name):
		#full_tag_list.remove_at(item_index)
		#added_tag_list.remove_item(item_index)
		#return
	#
	#remove_from_category(tags_inputed[tag_name]["category"])
	#
	#if character_genders.has(tag_name):
		#genders_added -= 1
	#elif character_bodytypes.has(tag_name):
		#body_types_added -= 1
#
	#tags_inputed.erase(tag_name)
	#full_tag_list.remove_at(item_index)
	#added_tag_list.remove_item(item_index)
	#regenerate_parents()
	#check_minimum_requirements()
	#
	#if tag_name in tag_queue:
		#tag_holder.remove_from_api_queue(tag_name, self, 1)


func remove_tag_simple(item_index: int) -> void: # Connect to itemlist activate
	var tag_name = added_tag_list.get_item_text(item_index)
	added_tag_list.remove_item(item_index)

	if tag_name in tag_queue:
		tag_holder.remove_from_api_queue(tag_name, self, 1)



#func remove_simple_tag(item_index: int) -> void: # Connect to itemlist activate
	#var item_metadata: Dictionary = added_tag_list.get_item_metadata(item_index)
	#var tag_text: String = added_tag_list.get_item_text(item_index)
	#
	#if added_tag_list.get_item_text(item_index) == "zero pictured":
		#zero_pictured = false
#
	#remove_from_category(item_metadata["category"])
	#
	#if character_genders.has(tag_text):
		#genders_added -= 1
	#elif character_bodytypes.has(tag_text):
		#body_types_added -= 1
	#
	#item_metadata = {}
	#added_tag_list.remove_item(item_index)
	#regenerate_parents_simple()
	#check_minimum_requirements()
	#
	#if tag_text in tag_queue:
		#tag_holder.remove_from_api_queue(tag_text, self, 1)


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


func add_from_suggested(item_activated: int, list_reference: ItemList) -> void: # Connect to item activated
	var _tag_text = list_reference.get_item_text(item_activated)
	
	if _tag_text.begins_with("*") or _tag_text.ends_with("*"):
		if 1 < _tag_text.split("*", false).size():
			var tag_sh_key: Dictionary = add_custom_tag.get_valid_somefix(_tag_text)
			
			add_custom_tag.open_with_tag(_tag_text, tag_sh_key["prefix"], tag_sh_key["suffix"])
			add_suggested_special.show()
			_tag_text = await add_custom_tag.tag_confirmed
			add_suggested_special.hide()
			if Tagger.settings.remove_prompt_sugg_on_use:
				list_reference.remove_item_from_list(item_activated)
	
	elif _tag_text.begins_with("|") and _tag_text.ends_with("|"):
		suggestion_or_adder.populate_menu(_tag_text)
		or_adder.show()
		_tag_text = await suggestion_or_adder.option_selected
		or_adder.hide()
		if Tagger.settings.remove_prompt_sugg_on_use:
			list_reference.remove_item_from_list(item_activated)
	
	elif _tag_text.begins_with("#"):
		number_tag_tool.set_tool(_tag_text.trim_prefix("#"))
		spinbox_adder.show()
		number_tag_tool.steal_focus()
		_tag_text = await number_tag_tool.number_chosen
		number_tag_tool.drop_focus()
		spinbox_adder.hide()
		if Tagger.settings.remove_prompt_sugg_on_use:
			list_reference.remove_item_from_list(item_activated)
	
	else:
		list_reference.remove_item_from_list(item_activated)
	
	add_simple_tag(_tag_text)


func clear_all_tags_simple() -> void: # Connect to clear all dropdown menu
	if tag_holder.active_instance != instance_name:
		return
	special_suggestions_item_list.clear()
	added_tag_list.clear()
	suggested_list.clear()
	
	final_tag_list_array.clear()
	final_tag_list.clear()


func clear_inputted_tags() -> void: # Connect to clear tags button
	added_tag_list.clear()
	final_tag_list.clear()


func clear_suggestion_tags() -> void: # Connect to clear suggeted button
	if tag_holder.active_instance != instance_name:
		return

	suggested_list.clear()


func load_tag_list(tags_to_load: Array, replace_tags: bool) -> void:
	if replace_tags:
		added_tag_list.clear()
		suggested_list.clear()
	
	for tag in tags_to_load:
		add_simple_tag(Tagger.alias_database.get_alias(tag), false)


# Called by wizard
func load_tag_dict(dict_to_load: Dictionary, replace_tags: bool) -> void:
	var item_index: int = 0
	if replace_tags:
		added_tag_list.clear()
		suggested_list.clear()
	if dict_to_load.has("artist"):
		for artist in dict_to_load["artist"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(artist), false)
			if item_index != -1:
				change_tag_category(item_index, Tagger.Categories.ARTIST)
	if dict_to_load.has("meta"):
		for meta_tag in dict_to_load["meta"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(meta_tag), false)
			if item_index != -1:
				change_tag_category(item_index, Tagger.Categories.META)
	if dict_to_load.has("characters"):
		for chara_tag in dict_to_load["characters"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(chara_tag), false)
			if item_index != -1:
				change_tag_category(item_index, Tagger.Categories.CHARACTER)
	if dict_to_load.has("species"):
		for spec_tag in dict_to_load["species"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(spec_tag), false)
			if item_index != -1:
				change_tag_category(item_index, Tagger.Categories.SPECIES)
	if dict_to_load.has("genders"):
		for gender_tag in dict_to_load["genders"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(gender_tag), false)
			if item_index != -1:
				change_tag_category(item_index, Tagger.Categories.GENDER)
	if dict_to_load.has("lore"):
		for lore_tag in dict_to_load["lore"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(lore_tag), false)
			if item_index != -1:
				change_tag_category(item_index, Tagger.Categories.LORE)
	
	if dict_to_load.has("actions_and_interactions"):
		for aai_tag in dict_to_load["actions_and_interactions"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(aai_tag), false)
			if item_index != -1:
				change_tag_category(item_index, Tagger.Categories.ACTIONS_AND_INTERACTIONS)
	if dict_to_load.has("body_types"):
		for bod_type_tag in dict_to_load["body_types"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(bod_type_tag), false)
			if item_index != -1:
				change_tag_category(item_index, Tagger.Categories.BODY_TYPES)
	if dict_to_load.has("poses_and_stances"):
		for pos_tag in dict_to_load["poses_and_stances"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(pos_tag), false)
			if item_index != -1:
				change_tag_category(item_index, Tagger.Categories.POSES_AND_STANCES)
	if dict_to_load.has("sex_and_positions"):
		for sex_tag in dict_to_load["sex_and_positions"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(sex_tag), false)
			if item_index != -1:
				change_tag_category(item_index, Tagger.Categories.SEX_AND_POSITIONS)
	if dict_to_load.has("general"):
		for gen_tag in dict_to_load["general"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(gen_tag), false)
	if dict_to_load.has("clothing"):
		for cloth_tag in dict_to_load["clothing"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(cloth_tag), false)
			if item_index != -1:
				change_tag_category(item_index, Tagger.Categories.CLOTHING)
	if dict_to_load.has("location"):
		for loc_tag in dict_to_load["location"]:
			item_index = add_simple_tag(Tagger.alias_database.get_alias(loc_tag), false)
			if item_index != -1:
				change_tag_category(item_index, Tagger.Categories.LOCATION)
	
	if dict_to_load.has("suggestions"):
		for sugg_tag in dict_to_load["suggestions"]:
			add_suggested_tag_simple(sugg_tag)
# ------------------------------------------------------


func disconnect_and_free() -> void:
	close_instance()
	if tagger_menu_bar.id_pressed.is_connected(tagger_menu_pressed):
		tagger_menu_bar.id_pressed.disconnect(tagger_menu_pressed)
	tagger_menu_bar = null
	main_application = null
	tag_holder = null
	self.queue_free()


func open_context_menu(tag_name: String, itembox_position: Vector2, item_position: Vector2, is_delete_allowed: bool, who_called: ItemList, item_index: int) -> void:
	context_tag = tag_name
	tagger_context_menu.position = itembox_position + item_position
	list_called = who_called
	called_index = item_index
	
	if Tagger.tag_manager.has_tag(tag_name):
		tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(0), true)
		tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(1), false)
		tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(2), false)
	else:
		tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(0), false)
		tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(1), true)
		tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(2), true)
	
	tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(3), not is_delete_allowed)
	
	if who_called == added_tag_list:
		tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(4), Tagger.tag_manager.has_tag(context_tag))
		tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(5), true)
	else:
		tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(4), true)
		tagger_context_menu.set_item_disabled(tagger_context_menu.get_item_index(5), true)

	if 720 < (tagger_context_menu.position.y + tagger_context_menu.size.y):
		var extrapiece = tagger_context_menu.size.y - (720 - tagger_context_menu.position.y)
		tagger_context_menu.position.y -= extrapiece 
	
	tagger_context_menu.show()


func left_click_context_menu_clicked(id_pressed: int) -> void:
	if id_pressed == 0:
		main_application.go_to_create_tag(context_tag)
	elif id_pressed == 1:
		main_application.go_to_edit_tag(context_tag)
	elif id_pressed == 2:
		main_application.go_to_wiki(context_tag)
	elif id_pressed == 3:
		list_called.remove_item_from_list(called_index)
	elif id_pressed == 4:
		open_set_tagger()
	elif id_pressed == 5:
		add_from_suggested(called_index, list_called)


func open_prompt_tag_window() -> void:
	if tag_holder.active_instance != instance_name:
		return
	add_prompt_tag()


func sort_tags_by_category() -> void:
	if tag_holder.active_instance != instance_name:
		return
	
	if added_tag_list.item_count < 2:
		return
	
	#var reference_array: Array = [
		#Tagger.Categories.ARTIST,
		#Tagger.Categories.COPYRIGHT,
		#Tagger.Categories.META,
		#Tagger.Categories.CHARACTER,
		#Tagger.Categories.SPECIES,
		#Tagger.Categories.GENDER,
		#Tagger.Categories.LORE,
	#]
	
	var mega_array = [{}, {}, {}, {}, {}, {}, {}, {}]
	
	var item_metadata: Dictionary = {}
	for tag_index in range(added_tag_list.item_count):
		item_metadata = added_tag_list.get_item_metadata(tag_index)
		
		if item_metadata["category"] == Tagger.Categories.ARTIST:
			mega_array[0][added_tag_list.get_item_text(tag_index)] = item_metadata.duplicate()
		elif item_metadata["category"] == Tagger.Categories.COPYRIGHT:
			mega_array[1][added_tag_list.get_item_text(tag_index)] = item_metadata.duplicate()
		elif item_metadata["category"] == Tagger.Categories.META:
			mega_array[2][added_tag_list.get_item_text(tag_index)] = item_metadata.duplicate()
		elif item_metadata["category"] == Tagger.Categories.CHARACTER:
			mega_array[3][added_tag_list.get_item_text(tag_index)] = item_metadata.duplicate()
		elif item_metadata["category"] == Tagger.Categories.SPECIES:
			mega_array[4][added_tag_list.get_item_text(tag_index)] = item_metadata.duplicate()
		elif item_metadata["category"] == Tagger.Categories.GENDER:
			mega_array[5][added_tag_list.get_item_text(tag_index)] = item_metadata.duplicate()
		elif item_metadata["category"] == Tagger.Categories.LORE:
			mega_array[6][added_tag_list.get_item_text(tag_index)] = item_metadata.duplicate()
		else:
			mega_array[7][added_tag_list.get_item_text(tag_index)] = item_metadata.duplicate()
		
		clear_inputted_tags()
		
		for dict:Dictionary in mega_array:
			var array_sort: Array = dict.keys()
			array_sort.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
			for tag in array_sort:
				var tag_ix = added_tag_list.add_item(tag)
				
				added_tag_list.set_item_metadata(
					tag_ix,
					dict[tag].duplicate())
				
				added_tag_list.set_item_custom_fg_color(
						tag_ix,
						Tagger.settings.category_color_code[
							Tagger.Categories.keys()[dict[tag]["category"]]
						])
				
				if Tagger.tag_manager.has_tag(tag):
					added_tag_list.set_item_tooltip(
							tag_ix,
							Tagger.tag_manager.get_tag(tag).tooltip)


func tagger_menu_pressed(option_id: int) -> void:
	if is_any_window_open():
		return
	
	if option_id == 0:
		clear_all_tags_simple()
	elif option_id == 1:
		clear_suggestion_tags()
	elif option_id == 4:
		show_conflicting_tags()
	elif option_id == 8:
		sort_tags_by_category()
	elif option_id == 9:
		open_wizard()
	elif option_id == 11:
		open_template_loader()
	elif option_id == 12:
		open_prompt_tag_window()


func change_tag_priority(tag_index: int, tag_priority: int) -> void:
	added_tag_list.get_item_metadata(tag_index)["priority"] = tag_priority


func change_tag_category(tag_index: int, tag_category: Tagger.Categories) -> void:
	added_tag_list.get_item_metadata(tag_index)["category"] = tag_category
	added_tag_list.set_item_custom_fg_color(
			tag_index,
			Tagger.settings.category_color_code[Tagger.Categories.keys()[tag_category]]
			)


func open_set_tagger() -> void:
	var tag_to_set: String = context_tag
	var _metadata: Dictionary = added_tag_list.get_item_metadata(called_index)
	
	set_as_tag.set_target_tag(tag_to_set, _metadata["category"], _metadata["priority"])
	set_as_tag.show()
	
	if await set_as_tag.set_as_accepted:
		if set_as_tag.change_prio:
			change_tag_priority(called_index, set_as_tag.prio_selected)
		if set_as_tag.change_category:
			change_tag_category(called_index, set_as_tag.category_select)
	set_as_tag.hide()


func open_wizard() -> void:
	if tag_holder.active_instance != instance_name:
		return
	
	tag_wizard.magic_clean()
	weezard.show()
	var tags_dict: Dictionary = await tag_wizard.wizard_tags_created
	weezard.hide()
	load_tag_dict(tags_dict, false)


func show_conflicting_tags() -> void:
	if tag_holder.active_instance != instance_name:
		return
	
	conflicting_tags.show()


func generate_tag_list() -> void:
	var site_key: String = Tagger.available_sites[available_sites.selected]
	var tag_dict: Dictionary = {"0": []}
	var prio_array: Array[int] = []
	tag_list_generator._dad_queue.clear()
	final_tag_list_array.clear()
	final_tag_list.clear()

	for added_ix in range(added_tag_list.item_count):
		var item_metadata: Dictionary = added_tag_list.get_item_metadata(added_ix)
		if not tag_dict.has(str(item_metadata["priority"])):
			tag_dict[str(item_metadata["priority"])] = []
		
		tag_dict[str(item_metadata["priority"])].append(added_tag_list.get_item_text(added_ix))
		
		tag_list_generator._dad_queue.append_array(item_metadata["parents"])
	
	tag_list_generator.explore_parents_v3()
	
	for parent_tag in tag_list_generator._kid_return:
		if Tagger.tag_manager.has_tag(parent_tag):
			var tag_prio: String = str(Tagger.tag_manager.get_tag(parent_tag).tag_priority)
			
			if not tag_dict.has(tag_prio):
				tag_dict[tag_prio] = []
			
			tag_dict[tag_prio].append(parent_tag)
			
		else:
			tag_dict["0"].append(parent_tag)
	
	for int_string in tag_dict.keys():
		prio_array.append(int(int_string))
	
	prio_array.sort()
	prio_array.reverse()
	
	for prio in prio_array:
		final_tag_list_array.append_array(
			tag_dict[str(prio)]
		)

	final_tag_list.text = tag_list_generator.create_list_from_array(
			final_tag_list_array,
			Tagger.site_settings.valid_sites[site_key]["whitespace"],
			Tagger.site_settings.valid_sites[site_key]["separator"])


func copy_resut_to_clipboard() -> void:
	if final_tag_list.text == "":
		return
	
	DisplayServer.clipboard_set(final_tag_list.text)
	copy_to_clipboard.text = "Copied!"
	copy_timer.start()


func on_copy_timer_timeout() -> void:
	copy_to_clipboard.text = "Copy to Clipboard"


func open_export_dialog() -> void:
	if final_tag_list.text.is_empty():
		return
	
	tag_file_dialog.tag_string = final_tag_list.text
	
	if tag_file_dialog.default_filename.is_empty():
		tag_file_dialog.default_filename = instance_name.validate_filename()
	
	if tag_file_dialog.default_path.is_empty():
		tag_file_dialog.default_path = Tagger.settings.default_save_path
	
	tag_file_dialog.show_dialog()


func change_platform(site_id: int) -> void:
	var site_key: String = Tagger.available_sites[site_id]
	tag_list_generator.target_site = site_key
	if not final_tag_list_array.is_empty():
		final_tag_list.text = tag_list_generator.create_list_from_array(
			final_tag_list_array,
			Tagger.site_settings.valid_sites[site_key]["whitespace"],
			Tagger.site_settings.valid_sites[site_key]["separator"])


func add_prompt_tag() -> void:
	prompt_tag_window.show()
	special_add.load_categories()
	special_add.reset_selections()
	var prompt_response: String = await special_add.item_selected
	prompt_tag_window.hide()
	if prompt_response.is_empty():
		return
	add_simple_tag(prompt_response, false)

