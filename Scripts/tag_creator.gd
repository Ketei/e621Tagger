extends Control

signal tag_created(tag_name)

@onready var tag_to_add_line_edit: LineEdit = $TagToAddLineEdit
@onready var categories_menu: OptionButton = $CategoriesMenu
@onready var create_tags_button = $CreateTagsButton
@onready var wiki_info = $WikiInfo
@onready var add_parent_line_edit = $AddParentLineEdit
@onready var parent_item_list: ItemList = $ParentItemList
@onready var tag_prio_box: SpinBox = $TagPrioBox
@onready var suggestion_item_list: ItemList = $SuggestionItemList
@onready var suggestion_line_edit: LineEdit = $SugestionLineEdit
@onready var has_images_check_box: CheckBox = $HasImagesCheckBox
@onready var tag_creator_menu: PopupMenu = $"../MenuBar/Tag Creator"
@onready var conflicts_line_edit: LineEdit = $ConflictWindow/ConflictsLineEdit
@onready var conflict_item_list: ItemList = $ConflictWindow/ConflictItemList
@onready var conflict_window = $ConflictWindow
@onready var download_samples_check_box: CheckBox = $DownloadSamplesCheckBox
@onready var e621_samples_downloader = $e621SamplesDownloader
@onready var samples_cooldown_timer: Timer = $SamplesCooldownTimer
@onready var tooltip_line_edit: LineEdit = $TooltipLineEdit

@onready var bbc_preview_button: Button = $BBCPreviewButton
@onready var preview_bbc_window = $PreviewBBCWindow
@onready var rich_text_label: RichTextLabel = $PreviewBBCWindow/Window/ColorBorder/CenterContainer/WikiDisplayRTLabel



var parent_tags: Array = []
var conflicts_array: Array[String] = []

var text_timer: Timer

var tag_suggestion_array: Array[String] = []

var samples_downloader_queue: Dictionary = {}
var is_downloading_samples: bool = false

func _ready():
	hide()
	
	bbc_preview_button.pressed.connect(preview_bcc)
	
	has_images_check_box.toggled.connect(has_images_toggled)
	
	e621_samples_downloader.images_saved.connect(next_in_samples_queue)
	
	tag_creator_menu.set_item_checked(tag_creator_menu.get_item_index(1), Tagger.settings.open_tag_folder_on_creation)
	
	conflicts_line_edit.text_submitted.connect(add_to_conflicts)
	conflict_item_list.item_activated.connect(remove_from_conflict)
	
	tag_creator_menu.id_pressed.connect(tag_creator_menu_changed)
	suggestion_line_edit.text_submitted.connect(add_suggestion)
	suggestion_item_list.item_activated.connect(remove_suggestion)

	create_tags_button.pressed.connect(create_tag)
	tag_to_add_line_edit.text_changed.connect(check_if_can_add_tag)
	add_parent_line_edit.text_submitted.connect(add_parent)
	parent_item_list.item_activated.connect(remove_parent)
	
	text_timer = Timer.new()
	text_timer.wait_time = 2.0
	text_timer.autostart = false
	text_timer.one_shot = true
	text_timer.timeout.connect(on_timer_timeout)
	add_child(text_timer)


func preview_bcc() -> void:
	rich_text_label.text = wiki_info.text
	preview_bbc_window.show()


func has_images_toggled(is_toggled: bool) -> void:
	download_samples_check_box.disabled = not is_toggled


func add_to_conflicts(conflict_name: String) -> void:
	conflict_name = conflict_name.strip_edges().to_lower()
	
	if conflict_name.is_empty():
		conflicts_line_edit.clear()
		return
	
	conflict_item_list.add_item(conflict_name)
	conflicts_array.append(conflict_name)
	conflicts_line_edit.clear()


func remove_from_conflict(conflict_index: int) -> void:
	conflicts_array.remove_at(conflict_index)
	conflict_item_list.remove_item(conflict_index)


func tag_creator_menu_changed(id_selected: int) -> void:
	if id_selected == 1: # Open folder
		var tag_index: int = tag_creator_menu.get_item_index(1)
		tag_creator_menu.set_item_checked(tag_index, not tag_creator_menu.is_item_checked(tag_index))
		Tagger.settings.open_tag_folder_on_creation = tag_creator_menu.is_item_checked(tag_index)
	elif id_selected == 2:
		conflict_window.show()
	elif id_selected == 3:
		clear_menu_items("", false)


func add_suggestion(new_suggestion: String) -> void:
	new_suggestion = new_suggestion.strip_edges().to_lower()
	
	if new_suggestion.is_empty() or tag_suggestion_array.has(new_suggestion):
		suggestion_line_edit.clear()
		if tag_suggestion_array.has(new_suggestion):
			suggestion_item_list.select(tag_suggestion_array.find(new_suggestion))
			suggestion_item_list.ensure_current_is_visible()
		return
	
	if not tag_suggestion_array.has(new_suggestion):
		tag_suggestion_array.append(new_suggestion)
		suggestion_item_list.add_item(new_suggestion)
		suggestion_line_edit.clear()


func remove_suggestion(item_id: int) -> void:
	tag_suggestion_array.remove_at(item_id)
	suggestion_item_list.remove_item(item_id)


func check_if_can_add_tag(new_text: String) -> void:
	if new_text == "" and not create_tags_button.disabled:
		create_tags_button.disabled = true
	elif new_text != "" and create_tags_button.disabled:
		create_tags_button.disabled = false


func add_parent(new_parent:String) -> void:
	new_parent = new_parent.to_lower().strip_edges()

	if new_parent.is_empty():
		return
	
	if new_parent.is_empty() or parent_tags.has(new_parent):
		add_parent_line_edit.clear()
		if parent_tags.has(new_parent):
			parent_item_list.select(parent_tags.find(new_parent))
			parent_item_list.ensure_current_is_visible()
		return
	
	parent_tags.append(new_parent)
	parent_item_list.add_item(new_parent)
	add_parent_line_edit.clear()


func remove_parent(parent_index: int) -> void:
	parent_tags.remove_at(parent_index)
	parent_item_list.remove_item(parent_index)


func create_tag() -> void:
	var target_tag: String = tag_to_add_line_edit.text
	target_tag = target_tag.strip_edges().to_lower()
	if Tagger.tag_manager.has_tag(target_tag):
		clear_menu_items("Tag already exists!!!")
		return

	var _tag_path: String = TagMaker.make_tag(
			target_tag,
			parent_tags,
			categories_menu.selected,
			wiki_info.text,
			int(tag_prio_box.value),
			tag_suggestion_array,
			has_images_check_box.button_pressed,
			conflicts_array,
			tooltip_line_edit.text.strip_edges()
			)
	
	if not Tagger.tag_manager.relation_database.has(target_tag.left(1)):
		Tagger.tag_manager.relation_database[target_tag.left(1)] = {}
	
	Tagger.tag_manager.relation_database[target_tag.left(1)][target_tag] = _tag_path
	
	if has_images_check_box.button_pressed and tag_creator_menu.is_item_checked(tag_creator_menu.get_item_index(1)):
		OS.shell_open(ProjectSettings.globalize_path(Tagger.tag_images_path + _tag_path.get_file().get_basename()))
	
	if download_samples_check_box.button_pressed and has_images_check_box.button_pressed:
		var search_tags: Array[String] = ["~type:jpg", "~type:png", "order:score"]
		
		for blacklist_tag in Tagger.settings_lists.samples_blacklist:
			if blacklist_tag == target_tag:
				continue
			search_tags.append("-" + blacklist_tag)
		
		search_tags.append(target_tag)
		
		samples_downloader_queue[Tagger.tag_images_path + _tag_path.get_file().get_basename() + "/"] = search_tags
		
		if not is_downloading_samples:
			download_samples()
		
	clear_menu_items("Done!")
	
	tag_created.emit(target_tag)


func download_samples() -> void:
	is_downloading_samples = true
	var key_to_download: String = samples_downloader_queue.keys().front()
	
	e621_samples_downloader.match_name = samples_downloader_queue[key_to_download].duplicate()
	e621_samples_downloader.save_on_finish = true
	e621_samples_downloader.path_to_save_to = key_to_download
	e621_samples_downloader.get_posts()
	
	samples_downloader_queue.erase(key_to_download)


func next_in_samples_queue() -> void:
	if samples_downloader_queue.is_empty():
		is_downloading_samples = false
		return
	else:
		await get_tree().create_timer(10.0).timeout
		download_samples()


func clear_menu_items(btn_message: String, change_text: bool = true) -> void:
	download_samples_check_box.button_pressed = false
	has_images_check_box.button_pressed = true
	conflict_item_list.clear()
	conflicts_array.clear()
	tag_suggestion_array.clear()
	suggestion_item_list.clear()
	suggestion_line_edit.clear()
	tag_prio_box.set_value_no_signal(0)
	categories_menu.select(0)
	tag_to_add_line_edit.clear()
	add_parent_line_edit.clear()
	parent_tags.clear()
	parent_item_list.clear()
	wiki_info.clear()
	
	if change_text:
		create_tags_button.text = btn_message
		text_timer.start()


func on_timer_timeout() -> void:
	create_tags_button.text = "Create Tag"

