extends Control

signal _finished_loading_local()
signal tag_updated

@export var alias_itemlist: ItemList
@export var add_alias_lineedit: LineEdit
@export var aliases_window: Control

@export var tag_searcher: LineEdit
@export var tag_search_button: Button
@export var name_line: LineEdit
@export var categories_menu: OptionButton
@export var wiki_edit: TextEdit
@export var tag_update_button: Button

@export var parents_item_list: ItemList
@export var add_parent_line_edit: LineEdit

@export var tag_prio_box: SpinBox

@export var tag_suggestion_list: ItemList
@export var tag_suggestion_line_edit: LineEdit

@export var review_menu: PopupMenu
@export var has_images_check_box: CheckBox

@export var open_pic_folder_button: Button

@export var add_conflict_line_edit: LineEdit
@export var conflicts_item_list: ItemList
@onready var conflict_window = $ConflictWindow
@export var tag_tooltip_line_edit: LineEdit

var conflicts_array: Array[String] = []

var parents: Array = []
var suggestions_array: Array[String] = []

@export var text_change_timer: Timer
#@export var downloading_samples_label: Label
#@onready var e621_samples_dl_review = $e621SamplesDLReview
@export var preview_bbc_button: Button
@export var rich_text_label: RichTextLabel
@export var preview_bbc_window: Control

@onready var open_auto_complete_parents_btn: Button = $AllItemsHBox/LeftVbox/ItemListsHBox/ParentTagsVbox/PArentsLineHbox/OpenAutoCompleteBTN
@onready var open_auto_complete_suggestions_btn: Button = $AllItemsHBox/LeftVbox/ItemListsHBox/SuggestionsVbox/SuggestionItemsHBox/OpenAutoCompleteBTN
@onready var show_prompts_btn: CheckButton = $AllItemsHBox/LeftVbox/SearcherHBox/ShowPromptsBtn
@onready var prompt_includer = $AllItemsHBox/PromtIncluder
@onready var has_prompt_data: CheckBox = $AllItemsHBox/LeftVbox/TagNameHbox/VBoxContainer/HasPromptData
@onready var right_v_box = $AllItemsHBox/RightVBox



#var samples_downloader_queue: Dictionary = {}
#var is_downloading_samples: bool = false:
#	set(value):
#		is_downloading_samples = value
#		downloading_samples_label.visible = is_downloading_samples
var delete_with_folder: bool = false

var tag_aliases_array: Array = []


func _ready():
	hide()
	prompt_includer.hide()
	show_prompts_btn.toggled.connect(on_prompt_visibility_toggle)
	parents_item_list.associated_array = parents
	tag_suggestion_list.associated_array = suggestions_array
	
	preview_bbc_button.pressed.connect(preview_bcc)
	delete_with_folder = Tagger.settings.delete_with_pictures
	
	review_menu.set_item_checked(
			review_menu.get_item_index(3),
			Tagger.settings.delete_with_pictures)
	
	review_menu.set_item_tooltip(
			review_menu.get_item_index(3),
			"If enabled when deleting a tag, the pictures folder will be 
			deleted as well.")

#	e621_samples_dl_review.images_saved.connect(next_in_samples_queue)
	add_conflict_line_edit.text_submitted.connect(add_tag_conflict)
	conflicts_item_list.item_activated.connect(remove_tag_conflict)
	
	open_pic_folder_button.pressed.connect(open_pics_folder)
	has_images_check_box.toggled.connect(image_checkbox_toggle)

	tag_suggestion_line_edit.text_submitted.connect(add_suggested)
	tag_suggestion_list.item_activated.connect(remove_suggested)
	tag_suggestion_list.search_for_tag.connect(search_for_tag)
	
	text_change_timer.timeout.connect(_on_timer_timeout)
	
	tag_searcher.text_submitted.connect(search_for_tag)
	tag_search_button.pressed.connect(button_search_pressed)
	tag_update_button.pressed.connect(update_tag)
	
	review_menu.id_pressed.connect(activate_menu_bar)
	
	parents_item_list.item_activated.connect(remove_parent)
	parents_item_list.search_for_tag.connect(search_for_tag)
	
	add_parent_line_edit.text_submitted.connect(add_parent)
	alias_itemlist.item_activated.connect(remove_alias)
	add_alias_lineedit.text_submitted.connect(add_tag_alias)


func on_prompt_visibility_toggle(is_toggled: bool) -> void:
	prompt_includer.visible = is_toggled
	right_v_box.visible = not is_toggled


func search_for_tag(new_text: String) -> void:
	if new_text.is_empty():
		clear_and_disable()
		return
	
	new_text = new_text.to_lower().strip_edges()
	new_text = Tagger.alias_database.get_alias(new_text)
	
	if not Tagger.tag_manager.has_tag(new_text):
		clear_and_disable()
		return
	
	conflicts_array.clear()
	conflicts_item_list.clear()
	
	parents.clear()
	parents_item_list.clear()
	
	tag_suggestion_list.clear()
	suggestions_array.clear()
	tag_suggestion_line_edit.clear()
	
	alias_itemlist.clear()
	tag_aliases_array.clear()
	
	prompt_includer.clear_fields()
	
	var _tag: Tag = Tagger.tag_manager.get_tag(new_text)

	name_line.text = _tag.tag
	categories_menu.select(_tag.category)

	for parent_tag in _tag.parents:
		parents.append(parent_tag)
		parents_item_list.add_item(parent_tag)
	
	for suggested_tag in _tag.suggestions:
		suggestions_array.append(suggested_tag)
		tag_suggestion_list.add_item(suggested_tag)
	
	for conflicting_tag in _tag.conflicts:
		conflicts_item_list.add_item(conflicting_tag)
		conflicts_array.append(conflicting_tag)
	
	for alias in _tag.aliases:
		alias_itemlist.add_item(alias)
		tag_aliases_array.append(alias)
	
	wiki_edit.clear()
	wiki_edit.text = _tag.wiki_entry
	tag_prio_box.set_value_no_signal(_tag.tag_priority)
	
	tag_tooltip_line_edit.clear()
	tag_tooltip_line_edit.text = _tag.tooltip
	
	has_images_check_box.button_pressed = _tag.has_pictures
	
	if has_images_check_box.button_pressed:
		open_pic_folder_button.disabled = false

	if _tag.has_prompt_data:
		has_prompt_data.button_pressed = true
		var prompt_tag: Dictionary =  {
			"category": _tag.prompt_category,
			"category_img": _tag.prompt_category_img_tag,
			"category_desc": _tag.prompt_category_desc,
			"subcategory": _tag.prompt_subcat,
			"subcategory_img": _tag.prompt_subcat_img_tag,
			"subcategory_desc": _tag.prompt_subcat_desc,
			"item_name": _tag.prompt_title,
			"item_desc": _tag.prompt_desc
		}
		prompt_includer.fill_data(prompt_tag)
	else:
		has_prompt_data.button_pressed = false
	
	has_prompt_data.disabled = false
	add_conflict_line_edit.editable = true
	has_images_check_box.disabled = false
	tag_suggestion_line_edit.editable = true
	tag_prio_box.editable = true
	add_parent_line_edit.editable = true
	categories_menu.disabled = false
	wiki_edit.editable = true
	tag_tooltip_line_edit.editable = true
	tag_update_button.disabled = false
	add_alias_lineedit.editable = true
	open_auto_complete_parents_btn.disabled = false
	open_auto_complete_suggestions_btn.disabled = false
	review_menu.set_item_disabled(review_menu.get_item_index(0), false)
	review_menu.set_item_disabled(review_menu.get_item_index(1), false)
	review_menu.set_item_disabled(review_menu.get_item_index(2), false)
	review_menu.set_item_disabled(review_menu.get_item_index(4), false)
	tag_searcher.clear()


func open_alias_window() -> void:
	aliases_window.show()


func update_tag() -> void:
	var are_prompts_good: bool = prompt_includer.is_valid_prompt()
	
	if has_prompt_data.button_pressed:
		if not are_prompts_good:
			prompt_includer.highlight_errors()
			return
	
	var _tag: Tag = Tagger.tag_manager.get_tag(name_line.text.to_lower())
	var prompt_data: Dictionary = prompt_includer.get_data()

	_tag.category = categories_menu.selected as Tagger.Categories
	_tag.parents = parents.duplicate()
	_tag.wiki_entry = wiki_edit.text
	_tag.tag_priority = int(tag_prio_box.value)
	_tag.suggestions = suggestions_array.duplicate()
	_tag.has_pictures = has_images_check_box.button_pressed
	_tag.conflicts = conflicts_array.duplicate()
	_tag.tooltip = tag_tooltip_line_edit.text.strip_edges()
	_tag.aliases = PackedStringArray(tag_aliases_array)
	_tag.prompt_category = prompt_data["category"]
	_tag.prompt_category_img_tag = prompt_data["category_img"]
	_tag.prompt_category_desc = prompt_data["category_desc"]
	_tag.prompt_subcat = prompt_data["subcategory"]
	_tag.prompt_subcat_img_tag = prompt_data["subcategory_img"]
	_tag.prompt_subcat_desc = prompt_data["subcategory_desc"]
	_tag.prompt_title = prompt_data["item_name"]
	_tag.prompt_desc = prompt_data["item_desc"]
	_tag.save()
	
	tag_updated.emit(_tag.tag)
	
	tag_update_button.text = "Updated!"
	text_change_timer.start()


func preview_bcc() -> void:
	rich_text_label.text = wiki_edit.text
	preview_bbc_window.show()


func add_tag_alias(alias_text: String) -> void:
	alias_text = alias_text.strip_edges().to_lower()
	add_alias_lineedit.clear()
	if tag_aliases_array.has(alias_text):
		return
	
	tag_aliases_array.append(alias_text)
	alias_itemlist.add_item(alias_text)


func remove_alias(alias_index: int) -> void:
	var alias_text: String = alias_itemlist.get_item_text(alias_index)
	tag_aliases_array.erase(alias_text)
	alias_itemlist.remove_item(alias_index)


func add_tag_conflict(tag_conflict: String) -> void:
	tag_conflict = tag_conflict.strip_edges().to_lower()
	
	if name_line.text == tag_conflict or conflicts_array.has(tag_conflict) or tag_conflict.is_empty():
		return
	
	conflicts_item_list.add_item(tag_conflict)
	conflicts_array.append(tag_conflict)
	add_conflict_line_edit.clear()


func remove_tag_conflict(index_id: int) -> void:
	conflicts_array.remove_at(index_id)
	conflicts_item_list.remove_item(index_id)


func open_pics_folder() -> void:
	var current_tag_filename: Tag = Tagger.tag_manager.get_tag(name_line.text)
	if not DirAccess.dir_exists_absolute(Tagger.tag_images_path + current_tag_filename.file_name.get_basename()):
		DirAccess.make_dir_absolute(Tagger.tag_images_path + current_tag_filename.file_name.get_basename())
	
	OS.shell_open(ProjectSettings.globalize_path(Tagger.tag_images_path + current_tag_filename.file_name.get_basename()))


func image_checkbox_toggle(new_toggle: bool) -> void:
	
	if new_toggle:
		open_pic_folder_button.disabled = false
	else:
		open_pic_folder_button.disabled = true


func delete_tag(tag_to_delete: String) -> void:
	if not Tagger.tag_manager.has_tag(tag_to_delete):
		return
	
	var _tag: Tag = Tagger.tag_manager.get_tag(tag_to_delete)
	var _tag_path = Tagger.tags_path + _tag.file_name
	
	if ResourceLoader.exists(_tag_path):
		OS.move_to_trash(ProjectSettings.globalize_path(_tag_path))
	
	if delete_with_folder and DirAccess.dir_exists_absolute(Tagger.tag_images_path + _tag.file_name.get_basename()):
		OS.move_to_trash(ProjectSettings.globalize_path(Tagger.tag_images_path + _tag.file_name.get_basename()))
	
	var _implication_replace: ImplicationDictionary = Tagger.tag_manager.get_implication(_tag.tag.left(1))
	_implication_replace.tag_implications.erase(_tag.tag)
	
	Tagger.tag_manager.relation_database[_implication_replace.implication_index].erase(_tag.tag)

	_implication_replace.save()


func activate_menu_bar(id_button: int) -> void:
	if id_button == 2: # Deleting a tag
		delete_tag(name_line.text.to_lower())
		clear_and_disable()
	
	elif id_button == 1: # Show conflicts
		conflict_window.show()
	elif id_button == 0: # Reload page
		search_for_tag(name_line.text)
	elif  id_button == 3: # Delete picture folder on deletion
		var is_enabled: bool = not review_menu.is_item_checked(
				review_menu.get_item_index(3))
		
		review_menu.set_item_checked(
				review_menu.get_item_index(3),
				is_enabled)
			
		Tagger.settings.delete_with_pictures = is_enabled
		delete_with_folder = is_enabled
	elif id_button == 4:
		if not aliases_window.visible:
			aliases_window.show()


func clear_and_disable() -> void:
	alias_itemlist.clear()
	tag_aliases_array.clear()
	add_alias_lineedit.clear()
	add_alias_lineedit.editable = false
	tag_tooltip_line_edit.clear()
	tag_tooltip_line_edit.editable = false
	conflicts_array.clear()
	conflicts_item_list.clear()
	add_conflict_line_edit.editable = false
	open_pic_folder_button.disabled = true
	has_images_check_box.button_pressed = false
	has_images_check_box.disabled = true
	tag_suggestion_list.clear()
	tag_suggestion_line_edit.clear()
	tag_suggestion_line_edit.editable = false
	tag_prio_box.set_value_no_signal(0)
	tag_prio_box.editable = false
	tag_searcher.clear()
	name_line.clear()
	categories_menu.select(0)
	categories_menu.disabled = true
	parents.clear()
	parents_item_list.clear()
	add_parent_line_edit.editable = false
	wiki_edit.clear()
	wiki_edit.editable = false
	prompt_includer.clear_fields()
	review_menu.set_item_disabled(review_menu.get_item_index(0), true)
	review_menu.set_item_disabled(review_menu.get_item_index(1), true)
	review_menu.set_item_disabled(review_menu.get_item_index(2), true)
	review_menu.set_item_disabled(review_menu.get_item_index(4), true)
	tag_update_button.disabled = true
	open_auto_complete_parents_btn.disabled = true
	open_auto_complete_suggestions_btn.disabled = true
	has_prompt_data.disabled = true


func button_search_pressed() -> void:
	search_for_tag(tag_searcher.text)


func add_parent(parent_text: String) -> void:
	parent_text = parent_text.strip_edges().to_lower()
	if parent_text.is_empty() or parents.has(parent_text):
		add_parent_line_edit.clear()
		return
	
	parent_text = parent_text.to_lower()
	
	parents.append(parent_text)
	parents_item_list.add_item(parent_text)
	add_parent_line_edit.clear()


func remove_parent(parent_id: int) -> void:
	parents.remove_at(parent_id)
	parents_item_list.remove_item(parent_id)


func add_suggested(new_suggestion: String) -> void:
	new_suggestion = new_suggestion.strip_edges().to_lower()
	tag_suggestion_line_edit.clear()
	
	if new_suggestion.is_empty() or suggestions_array.has(new_suggestion):
		return

	suggestions_array.append(new_suggestion)
	tag_suggestion_list.add_item(new_suggestion)


func remove_suggested(sug_id: int) -> void:
	suggestions_array.remove_at(sug_id)
	tag_suggestion_list.remove_item(sug_id)


func _on_timer_timeout() -> void:
	tag_update_button.text = "Update Tag"

