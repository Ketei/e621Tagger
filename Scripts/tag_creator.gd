extends Control

signal tag_created(tag_name)
signal register_alias(old_name, new_name)

@export var aliased_itemlist: ItemList
@export var alias_lineedit: LineEdit
@export var alias_window_control: Control

@onready var main_application = $".."
@onready var tag_to_add_line_edit: LineEdit = $VBoxContainer/HBoxContainer/LeftPartVBox/NameHBox/TagToAddLineEdit
@onready var categories_menu: OptionButton = $VBoxContainer/HBoxContainer/LeftPartVBox/CatPrioHBox/CategoryHBox/CategoriesMenu
@onready var create_tags_button = $VBoxContainer/CreateTagsButton
@onready var wiki_info = $VBoxContainer/HBoxContainer/RightPartVBox/WikiInfo
@export var add_parent_line_edit: LineEdit
@onready var parent_item_list: ItemList = $VBoxContainer/HBoxContainer/LeftPartVBox/HBoxContainer/ParentsVBox/ParentItemList
@onready var tag_prio_box: SpinBox = $VBoxContainer/HBoxContainer/LeftPartVBox/CatPrioHBox/PriorityHBox/TagPrioBox
@onready var suggestion_item_list: ItemList = $VBoxContainer/HBoxContainer/LeftPartVBox/HBoxContainer/SuggestionsVBox/SuggestionItemList
@export var suggestion_line_edit: LineEdit
@onready var has_images_check_box: CheckBox = $VBoxContainer/HBoxContainer/LeftPartVBox/NameHBox/VBoxContainer/HasImagesCheckBox
@onready var tag_creator_menu: PopupMenu = $"../MenuBar/Tag Creator"
@onready var conflicts_line_edit: LineEdit = $ConflictWindow/ConflictsLineEdit
@onready var conflict_item_list: ItemList = $ConflictWindow/ConflictItemList
@onready var conflict_window = $ConflictWindow
@onready var download_samples_check_box: CheckBox = $VBoxContainer/HBoxContainer/LeftPartVBox/NameHBox/VBoxContainer/DownloadSamplesCheckBox
@onready var tooltip_line_edit: LineEdit = $VBoxContainer/HBoxContainer/RightPartVBox/TooltipLineEdit

@onready var bbc_preview_button: Button = $BBCPreviewButton
@onready var preview_bbc_window = $PreviewBBCWindow
@onready var rich_text_label: RichTextLabel = $PreviewBBCWindow/Window/ColorBorder/CenterContainer/WikiDisplayRTLabel

@onready var e_621api_request: E621API = $"../e621APIRequest"
@onready var downloading_samples_lbl: Label = $DownloadingSamplesLbl
@onready var creator_pop_up_menu: PopupMenu = $CreatorPopUpMenu
@onready var include_in_prompts: CheckButton = $VBoxContainer/HBoxContainer/LeftPartVBox/NameHBox/VBoxContainer/CheckButton
@onready var center_part_v_box = $VBoxContainer/HBoxContainer/CenterPartVBox
@onready var prompt_includer = $VBoxContainer/HBoxContainer/CenterPartVBox/PromtIncluder

var parent_tags: Array = []
var conflicts_array: Array[String] = []
var aliased_tags: Array = []

var text_timer: Timer

var tag_suggestion_array: Array[String] = []

var samples_downloader_queue: Dictionary = {}

var downloads_queued: int = 0:
	set(value):
		downloads_queued = value
		if 0 == downloads_queued:
			downloading_samples_lbl.hide()
		else:
			downloading_samples_lbl.show()

var left_context_tag: String = ""

func _ready():
	hide()
	parent_item_list.associated_array = parent_tags
	suggestion_item_list.associated_array = tag_suggestion_array
	bbc_preview_button.pressed.connect(preview_bcc)
	include_in_prompts.toggled.connect(on_include_prompts)
	
	has_images_check_box.toggled.connect(has_images_toggled)
	
#	e621_samples_downloader.images_saved.connect(next_in_samples_queue)
	
	tag_creator_menu.set_item_checked(tag_creator_menu.get_item_index(1), Tagger.settings.open_tag_folder_on_creation)
	
	conflicts_line_edit.text_submitted.connect(add_to_conflicts)
	conflict_item_list.item_activated.connect(remove_from_conflict)
	
	tag_creator_menu.id_pressed.connect(tag_creator_menu_changed)
	suggestion_line_edit.text_submitted.connect(add_suggestion)
	suggestion_item_list.item_activated.connect(remove_suggestion)

	create_tags_button.pressed.connect(try_create_tag)
	add_parent_line_edit.text_submitted.connect(add_parent)
	parent_item_list.item_activated.connect(remove_parent)
	
	parent_item_list.open_context_clicked.connect(show_popup_menu)
	suggestion_item_list.open_context_clicked.connect(show_popup_menu)
	creator_pop_up_menu.id_pressed.connect(menu_id_pressed)
	
	text_timer = Timer.new()
	text_timer.wait_time = 2.0
	text_timer.autostart = false
	text_timer.one_shot = true
	text_timer.timeout.connect(on_timer_timeout)
	add_child(text_timer)
	
	alias_lineedit.text_submitted.connect(add_new_alias)
	aliased_itemlist.item_activated.connect(remove_alias_item)


func on_include_prompts(is_toggled: bool) -> void:
	if is_toggled:
		center_part_v_box.show()
	else:
		center_part_v_box.hide()


func show_popup_menu(tag_clicked: String, element_position: Vector2, item_position: Vector2, _is_delete_allowed: bool, _who_called: ItemList, _item_index: int) -> void:
	left_context_tag = tag_clicked
	creator_pop_up_menu.position = element_position + item_position
	creator_pop_up_menu.show()


func menu_id_pressed(menu_id: int) -> void:
	print(menu_id)
	if menu_id == 0:
		main_application.go_to_wiki(left_context_tag)


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
	elif id_selected == 4:
		if not alias_window_control.visible:
			alias_window_control.show()


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


func try_create_tag() -> void:
	var tag_name: bool = not tag_to_add_line_edit.text.strip_edges().is_empty()
	var prompts_activated: bool = include_in_prompts.button_pressed
	var prompts_valid: bool = prompt_includer.is_valid_prompt()
	
	var can_add: bool = false
	
	if prompts_activated:
		can_add = tag_name and prompts_valid
	else:
		can_add = tag_name
		
	if can_add:
		create_tag()
	else:
		if not prompts_valid:
			prompt_includer.highlight_errors()


func create_tag() -> void:
	var target_tag: String = tag_to_add_line_edit.text
	target_tag = target_tag.strip_edges().to_lower()
	if Tagger.tag_manager.has_tag(target_tag):
		clear_menu_items("Tag already exists!!!")
		return
	
	var prompt_data: Dictionary = {
		"category": "",
		"category_img": "",
		"category_desc": "",
		"subcategory": "",
		"subcategory_img": "",
		"subcategory_desc": "",
		"item_name": "",
		"item_desc": ""
		}
	
	if include_in_prompts.button_pressed:
		prompt_data = prompt_includer.get_data()
		prompt_includer.target_tag = target_tag
		prompt_includer.on_save()

	var _tag_path: String = TagMaker.make_tag(
		target_tag,
		parent_tags,
		categories_menu.get_item_id(categories_menu.selected),
		wiki_info.text,
		int(tag_prio_box.value),
		tag_suggestion_array,
		has_images_check_box.button_pressed,
		conflicts_array,
		tooltip_line_edit.text.strip_edges(),
		aliased_tags,
		prompt_data["category"],
		prompt_data["category_img"],
		prompt_data["category_desc"],
		prompt_data["subcategory"],
		prompt_data["subcategory_img"],
		prompt_data["subcategory_desc"],
		prompt_data["item_name"],
		prompt_data["item_desc"],
		include_in_prompts.button_pressed
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

		e_621api_request.add_to_queue(search_tags, 5, E621API.SEARCH_TYPES.DOWNLOAD, self, Tagger.tag_images_path + _tag_path.get_file().get_basename() + "/")
		downloads_queued += 1
	
	for alias in aliased_tags:
		register_alias.emit(alias, target_tag)
	
	clear_menu_items("Done!")
	
	tag_created.emit(target_tag)


func api_response(_response) -> void:
	downloads_queued -= 1


func clear_menu_items(btn_message: String, change_text: bool = true) -> void:
	aliased_tags.clear()
	aliased_itemlist.clear()
	alias_lineedit.clear()
	download_samples_check_box.button_pressed = false
	has_images_check_box.button_pressed = true
	tooltip_line_edit.clear()
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
	prompt_includer.clear_fields()
	
	if change_text:
		create_tags_button.text = btn_message
		text_timer.start()


func on_timer_timeout() -> void:
	create_tags_button.text = "Create Tag"


func add_new_alias(alias_string: String) -> void:
	alias_string = alias_string.strip_edges().to_lower()
	alias_lineedit.clear()
	
	if aliased_tags.has(alias_string):
		return
	
	aliased_tags.append(alias_string)
	aliased_itemlist.add_item(alias_string)


func remove_alias_item(item_index: int) -> void:
	var aliased_string: String = aliased_itemlist.get_item_text(item_index)
	aliased_tags.erase(aliased_string)
	aliased_itemlist.remove_item(item_index)

