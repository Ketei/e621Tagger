extends Control

signal _finished_loading_local()
signal tag_updated

@onready var tag_searcher = $TagSearcher
@onready var tag_search_button = $TagSearcher/TagSearchButton
@onready var name_line: LineEdit = $NameLine
@onready var categories_menu: OptionButton = $CategoriesMenu
@onready var wiki_edit = $WikiEdit
@onready var tag_update_button = $TagUpdate

@onready var parents_item_list: ItemList = $ParentsItemList
@onready var add_parent_line_edit: LineEdit = $AddParentLineEdit

@onready var tag_prio_box: SpinBox = $TagPrioBox

@onready var tag_suggestion_list: ItemList = $TagSuggestionList
@onready var tag_suggestion_line_edit: LineEdit = $TagSuggestionLineEdit

@onready var review_menu: PopupMenu = $"../MenuBar/Tag Editor"
@onready var has_images_check_box = $HasImagesCheckBox

@onready var open_pic_folder_button: Button = $OpenPicFolder

@onready var add_conflict_line_edit: LineEdit = $ConflictWindow/AddConflictLineEdit
@onready var conflicts_item_list: ItemList = $ConflictWindow/ConflictsItemList
@onready var conflict_window = $ConflictWindow
@onready var tag_tooltip_line_edit: LineEdit = $TagTooltipLineEdit

var conflicts_array: Array[String] = []

var parents: Array = []
var suggestions_array: Array[String] = []

@onready var text_change_timer: Timer = $TextChangeTimer
@onready var downloading_samples_label: Label = $DownloadingSamplesLabel
@onready var e621_samples_dl_review = $e621SamplesDLReview
@onready var preview_bbc_button: Button = $PreviewBBCButton
@onready var rich_text_label = $PreviewBBCWindow/Window/ColorBorder/CenterContainer/Control/RichTextLabel
@onready var preview_bbc_window = $PreviewBBCWindow

func preview_bcc() -> void:
	rich_text_label.text = wiki_edit.text
	preview_bbc_window.show()


var samples_downloader_queue: Dictionary = {}
var is_downloading_samples: bool = false:
	set(value):
		is_downloading_samples = value
		downloading_samples_label.visible = is_downloading_samples


func _ready():
	hide()
	
	preview_bbc_button.pressed.connect(preview_bcc)
	
	review_menu.set_item_tooltip(
			review_menu.get_item_index(5),
			"If enabled when deleting a tag, the pictures folder will be 
			deleted as well.")

	e621_samples_dl_review.images_saved.connect(next_in_samples_queue)
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
	

func update_tag() -> void:
	var _tag: Tag = Tagger.tag_manager.get_tag(name_line.text.to_lower())
	
	_tag.category = categories_menu.selected as Tagger.Categories
	_tag.parents = parents.duplicate()
	_tag.wiki_entry = wiki_edit.text
	_tag.tag_priority = int(tag_prio_box.value)
	_tag.suggestions = suggestions_array.duplicate()
	_tag.has_pictures = has_images_check_box.button_pressed
	_tag.conflicts = conflicts_array.duplicate()
	_tag.tooltip = tag_tooltip_line_edit.text.strip_edges()
	_tag.save()
	
	tag_updated.emit(_tag.tag)
	
	tag_update_button.text = "Updated!"
	text_change_timer.start()


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
	
	if Tagger.settings.delete_with_pictures and DirAccess.dir_exists_absolute(Tagger.tag_images_path + _tag.file_name.get_basename()):
		OS.move_to_trash(ProjectSettings.globalize_path(Tagger.tag_images_path + _tag.file_name.get_basename()))
	
	var _implication_replace: ImplicationDictionary = Tagger.tag_manager.get_implication(_tag.tag.left(1))
	_implication_replace.tag_implications.erase(_tag.tag)
	
	Tagger.tag_manager.relation_database[_implication_replace.implication_index].erase(_tag.tag)

	_implication_replace.save()


func activate_menu_bar(id_button: int) -> void:
	if id_button == 1: # Deleting a tag
		delete_tag(name_line.text.to_lower())
		clear_and_disable()
	
	elif id_button == 2: # Show conflicts
		conflict_window.show()
	
	elif id_button == 3: # Download samples
		add_to_download_queue()
	
	elif id_button == 4: # Reload page
		search_for_tag(name_line.text)
	elif  id_button == 5: # Delete picture folder on deletion
		var is_enabled: bool = not review_menu.is_item_checked(
				review_menu.get_item_index(5))
		
		review_menu.set_item_checked(
				review_menu.get_item_index(5),
				is_enabled)
			
		Tagger.settings.delete_with_pictures = is_enabled


func clear_and_disable() -> void:
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
	review_menu.set_item_disabled(review_menu.get_item_index(1), true)
	review_menu.set_item_disabled(review_menu.get_item_index(2), true)
	review_menu.set_item_disabled(review_menu.get_item_index(3), true)
	review_menu.set_item_disabled(review_menu.get_item_index(4), true)
	tag_update_button.disabled = true


func button_search_pressed() -> void:
	search_for_tag(tag_searcher.text)


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
	
	wiki_edit.clear()
	wiki_edit.text = _tag.wiki_entry
	tag_prio_box.set_value_no_signal(_tag.tag_priority)
	
	tag_tooltip_line_edit.clear()
	tag_tooltip_line_edit.text = _tag.tooltip
	
	has_images_check_box.button_pressed = _tag.has_pictures
	
	if has_images_check_box.button_pressed:
		open_pic_folder_button.disabled = false
	
	add_conflict_line_edit.editable = true
	has_images_check_box.disabled = false
	tag_suggestion_line_edit.editable = true
	tag_prio_box.editable = true
	add_parent_line_edit.editable = true
	categories_menu.disabled = false
	wiki_edit.editable = true
	tag_tooltip_line_edit.editable = true
	tag_update_button.disabled = false
	review_menu.set_item_disabled(review_menu.get_item_index(1), false)
	review_menu.set_item_disabled(review_menu.get_item_index(2), false)
	review_menu.set_item_disabled(review_menu.get_item_index(3), false)
	review_menu.set_item_disabled(review_menu.get_item_index(4), false)
	tag_searcher.clear()


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
	
	if new_suggestion.is_empty():
		tag_suggestion_line_edit.clear()
		return
	
	suggestions_array.append(new_suggestion)
	tag_suggestion_list.add_item(new_suggestion)
	tag_suggestion_line_edit.clear()


func remove_suggested(sug_id: int) -> void:
	suggestions_array.remove_at(sug_id)
	tag_suggestion_list.remove_item(sug_id)


func _on_timer_timeout() -> void:
	tag_update_button.text = "Update Tag"


func add_to_download_queue():
	if name_line.text.is_empty():
		return
	
	var tag: Tag = Tagger.tag_manager.get_tag(name_line.text)
	
	if samples_downloader_queue.has(Tagger.tag_images_path + tag.file_name.get_basename() + "/"):
		return
	
	var search_tags: Array[String] = ["~type:jpg", "~type:png", "order:score"]
		
	for blacklist_tag in Tagger.settings_lists.samples_blacklist:
		if blacklist_tag == name_line.text:
			continue
		search_tags.append("-" + blacklist_tag)
	
	search_tags.append(name_line.text)
	
	samples_downloader_queue[Tagger.tag_images_path + tag.file_name.get_basename() + "/"] = search_tags
	
	if not is_downloading_samples:
		download_samples()


func download_samples() -> void:
	is_downloading_samples = true
	var key_to_download: String = samples_downloader_queue.keys().front()
	
	e621_samples_dl_review.match_name = samples_downloader_queue[key_to_download].duplicate()
	e621_samples_dl_review.save_on_finish = true
	e621_samples_dl_review.path_to_save_to = key_to_download
	e621_samples_dl_review.get_posts()
	samples_downloader_queue.erase(key_to_download)


func next_in_samples_queue() -> void:
	if samples_downloader_queue.is_empty():
		is_downloading_samples = false
		return
	else:
		await get_tree().create_timer(10.0).timeout
		download_samples()

