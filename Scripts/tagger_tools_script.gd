extends Control

@onready var priority_spin_box: SpinBox = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/VBoxContainer/Searchers/PrioritySpinBox"
@onready var search_with_prio_button: Button = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/VBoxContainer/Buttons/SearchWithPrioButton"
@onready var category_opt_button: OptionButton = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/VBoxContainer/Searchers/CategoriesMenu"
@onready var search_with_cat_button: Button = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/VBoxContainer/Buttons/SearchWithCatButton"
@onready var new_cat_opt_button: OptionButton = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/VBoxContainer/DetailsMarginContainer/DetailsVBox/CategoryHBox/CategoriesMenu"
@onready var replace_cat_checkbox: CheckButton = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/VBoxContainer/DetailsMarginContainer/DetailsVBox/CategoryHBox/ReplaceCatCheckbox"
@onready var new_prio_button: SpinBox = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/VBoxContainer/DetailsMarginContainer/DetailsVBox/PriorityHBox/NewPrioButton"
@onready var replace_prio_checkbox: CheckButton = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/VBoxContainer/DetailsMarginContainer/DetailsVBox/PriorityHBox/ReplacePrioCheckbox"
@onready var mass_update_button: Button = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/VBoxContainer/MassUpdateButton"
@onready var results_item_list: ItemList = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/TagResultsVBox/ResultsItemList"
@onready var has_image_checkbox: CheckBox = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/VBoxContainer/DetailsMarginContainer/DetailsVBox/HasImgHBox/HasImageCheckbox"
@onready var replace_has_img_checkbox: CheckButton = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/VBoxContainer/DetailsMarginContainer/DetailsVBox/HasImgHBox/ReplaceHasImgCheckbox"
@onready var select_all_button: Button = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/TagResultsVBox/HBoxContainer/SelectAllButton"
@onready var deselect_all_button: Button = $"ToolsTabContainer/Mass Tags Editor/MassTagEditorHbox/TagResultsVBox/HBoxContainer/DeselectAllButton"

@onready var tag_reviewer = $"../TagReviewer"

@onready var main_application = $".."


func _ready():
	hide()
	
	search_with_prio_button.pressed.connect(search_threaded_priority)
#	search_with_cat_button.pressed.connect(search_with_category)
	search_with_cat_button.pressed.connect(search_threaded_category)
	
	replace_cat_checkbox.toggled.connect(replace_category_toggled)
	replace_prio_checkbox.toggled.connect(replace_priority_toggled)
	replace_has_img_checkbox.toggled.connect(replace_has_pic_toggled)
	mass_update_button.pressed.connect(mass_edit_selected)
	results_item_list.item_activated.connect(edit_item)
	deselect_all_button.pressed.connect(deselect_all_items)
	select_all_button.pressed.connect(select_all_items)


func search_threaded_category() -> void:
	results_item_list.clear()
	search_with_cat_button.disabled = true
	search_with_prio_button.disabled = true
	if is_instance_valid(Tagger.common_thread) and Tagger.common_thread.is_started():
		Tagger.common_thread.wait_to_finish()
	Tagger.common_thread.start(search_with_category.bind(Tagger.tag_manager.duplicate(false), category_opt_button.selected))


func search_threaded_priority() -> void:
	results_item_list.clear()
	search_with_cat_button.disabled = true
	search_with_prio_button.disabled = true
	if is_instance_valid(Tagger.common_thread) and Tagger.common_thread.is_started():
		Tagger.common_thread.wait_to_finish()
	Tagger.common_thread.start(search_with_priority.bind(Tagger.tag_manager.duplicate(false), priority_spin_box.value))


func add_results_to_itemlist(result_array: Array):
	for item in result_array:
		results_item_list.add_item(item)
	search_with_cat_button.disabled = false
	search_with_prio_button.disabled = false
	
	if is_instance_valid(Tagger.common_thread) and Tagger.common_thread.is_started():
		Tagger.common_thread.wait_to_finish()


func search_with_category(tag_manager: TagManager, category_selected: int) -> void: # Made for separate thread
	var category_array: Array = []
	var all_tags = tag_manager.get_all_tags()
	for tag_string in all_tags:
		var tag_get: Tag = tag_manager.get_tag(tag_string)
		if tag_get == null:
			continue
		if tag_get.category == category_selected: #category_opt_button.selected:
			category_array.append(tag_string)
	add_results_to_itemlist.call_deferred(category_array)


func search_with_priority(tag_manager: TagManager, priority_selected: int) -> void: # made for separate thread
	var internal_array: Array = []
	var all_tags = tag_manager.get_all_tags()
	for tag_string in all_tags:
		var tag_get: Tag = tag_manager.get_tag(tag_string)
		if tag_get == null:
			continue
		if tag_get.tag_priority == priority_selected: #priority_spin_box.value:
			internal_array.append(tag_string)
	add_results_to_itemlist.call_deferred(internal_array)


func edit_item(item_index: int) -> void:
	var tag_to_edit: String = results_item_list.get_item_text(item_index)
	tag_reviewer.search_for_tag(tag_to_edit)
	
	main_application.trigger_options(5)


func mass_edit_selected() -> void:
	if not results_item_list.is_anything_selected():
		return
	
	var selected_indexes: Array = results_item_list.get_selected_items()
	
	for index in selected_indexes:
		var _tag_to_update: Tag = Tagger.tag_manager.get_tag(results_item_list.get_item_text(index))
		
		if replace_has_img_checkbox.button_pressed:
			_tag_to_update.has_pictures = has_image_checkbox.button_pressed
		
		if replace_prio_checkbox.button_pressed:
			_tag_to_update.tag_priority = int(new_prio_button.value)
		
		if replace_cat_checkbox.button_pressed:
			_tag_to_update.category = new_cat_opt_button.selected as Tagger.Categories
		
		_tag_to_update.save()
		
	mass_update_button.text = "Success"
	await  get_tree().create_timer(1.0).timeout
	mass_update_button.text = "Update Selected"
	

func replace_category_toggled(new_toggle: bool) -> void:
	new_cat_opt_button.disabled = not new_toggle


func replace_priority_toggled(new_toggle: bool) -> void:
	new_prio_button.editable = new_toggle


func replace_has_pic_toggled(new_toggle: bool) -> void:
	has_image_checkbox.disabled = not new_toggle


func select_all_items() -> void:
	for index in range(results_item_list.item_count):
		results_item_list.select(index, false)


func deselect_all_items() -> void:
	if results_item_list.is_anything_selected():
		results_item_list.deselect_all()

