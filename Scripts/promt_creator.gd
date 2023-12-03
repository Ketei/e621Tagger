extends PanelContainer


signal prompt_done

var target_tag: String = ""

@export var hide_buttons: bool = false
@export var allow_key_edits: bool = true
@export var display_target_tag: bool = false
@export var force_key_save: bool = false
@export var start_disabled: bool = false
@export var hide_cancel: bool = false
@export_group("Specific_disables")
@export var disable_tag: bool = false
@export var disable_category: bool = false
@export var disable_cat_image: bool = false
@export var disable_cat_desc: bool = false
@export var disable_subcategory: bool = false
@export var disable_subcat_image: bool = false
@export var disable_subcat_desc: bool = false
@export var disable_item_name: bool = false
@export var disable_item_desc: bool = false

@onready var category_line_edit: LineEdit = $MarginContainer/VBoxContainer/Category/CategoryLineEdit
@onready var category_image_tag: LineEdit = $MarginContainer/VBoxContainer/CategoryImage/CategoryImageTag
@onready var category_desc: TextEdit = $MarginContainer/VBoxContainer/CategoryDesc/CategoryDesc

@onready var sub_category_line_edit: LineEdit = $MarginContainer/VBoxContainer/SubCategory/SubCategoryLineEdit
@onready var sub_category_image_tag: LineEdit = $MarginContainer/VBoxContainer/SubCategoryImage/SubCategoryImageTag
@onready var sub_category_desc: TextEdit = $MarginContainer/VBoxContainer/SubCategoryDesc/SubCategoryDesc
@onready var error_timer: Timer = $ErrorTimer

@onready var item_name: LineEdit = $MarginContainer/VBoxContainer/Name/ItemName
@onready var item_desc: TextEdit = $MarginContainer/VBoxContainer/ItemDesc/ItemDesc

@onready var cancel: Button = $MarginContainer/VBoxContainer/Buttons/Cancel
@onready var save: Button = $MarginContainer/VBoxContainer/Buttons/Save
@onready var buttons = $MarginContainer/VBoxContainer/Buttons
@onready var category_label: Label = $MarginContainer/VBoxContainer/Category/CategoryLabel
@onready var sub_cat_label: Label = $MarginContainer/VBoxContainer/SubCategory/SubCatLabel
@onready var item_name_label: Label = $MarginContainer/VBoxContainer/Name/ItemNameLabel
@onready var target_tag_field = $MarginContainer/VBoxContainer/TargetTag
@onready var tag_line_edit: LineEdit = $MarginContainer/VBoxContainer/TargetTag/TagLineEdit
@onready var tag_label: Label = $MarginContainer/VBoxContainer/TargetTag/TagLabel
@onready var disabled_rect = $DisabledRect


func _ready():
	error_timer.timeout.connect(on_timer_timeout)
	target_tag_field.visible = display_target_tag
	if hide_buttons:
		buttons.hide()
	else:
		save.pressed.connect(on_save)
		cancel.pressed.connect(on_cancel)
	
	if hide_cancel:
		cancel.hide()
	
	disabled_rect.visible = start_disabled
	
	if not allow_key_edits:
		category_line_edit.editable = false
		category_image_tag.editable = false
		category_desc.editable = false
		sub_category_line_edit.editable = false
		sub_category_image_tag.editable = false
		sub_category_desc.editable = false
		item_name.editable = false
		item_desc.editable = false
	#@export var disable_tag: bool = false
	#@export var disable_category: bool = false
	#@export var disable_cat_image: bool = false
	#@export var disable_cat_desc: bool = false
	#@export var disable_subcategory: bool = false
	#@export var disable_subcat_image: bool = false
	#@export var disable_subcat_desc: bool = false
	#@export var disable_item_name: bool = false
	#@export var disable_item_desc: bool = false
	if disable_tag:
		tag_line_edit.editable = false
	if disable_category:
		category_line_edit.editable = false
	if disable_cat_image:
		category_image_tag.editable = false
	if disable_cat_desc:
		category_desc.editable = false
	if disable_subcategory:
		sub_category_line_edit.editable = false
	if disable_subcat_image:
		sub_category_image_tag.editable = false
	if disable_subcat_desc:
		sub_category_desc.editable = false
	if disable_item_name:
		item_name.editable = false
	if disable_item_desc:
		item_desc.editable = false
	#save.pressed.connect(fix_tags)


func fix_tags() -> void:
	for category in Tagger.prompt_resources.prompt_list.keys():
		for subcategory in Tagger.prompt_resources.prompt_list[category]["types"].keys():
			for item in Tagger.prompt_resources.prompt_list[category]["types"][subcategory]["types"].keys():
				if Tagger.tag_manager.has_tag(Tagger.prompt_resources.prompt_list[category]["types"][subcategory]["types"][item]["tag"]):
					var _tag: Tag = Tagger.tag_manager.get_tag(Tagger.prompt_resources.prompt_list[category]["types"][subcategory]["types"][item]["tag"])
					load_prompt(category, subcategory, item)
					var all_data: Dictionary = get_data()
					_tag.prompt_category = all_data["category"]
					_tag.prompt_category_img_tag = all_data["category_img"]
					_tag.prompt_category_desc = all_data["category_desc"]
					_tag.prompt_subcat = all_data["subcategory"]
					_tag.prompt_subcat_img_tag = all_data["subcategory_img"]
					_tag.prompt_subcat_desc = all_data["subcategory_desc"]
					_tag.prompt_title = all_data["item_name"]
					_tag.prompt_desc = all_data["item_desc"]
					_tag.has_prompt_data = true
					_tag.save()
	print("done")


func get_data() -> Dictionary:
	return {
		"category": Utils.better_capitalize(category_line_edit.text.strip_edges()),
		"category_img": category_image_tag.text.strip_edges().to_lower(),
		"category_desc": category_desc.text.strip_edges(),
		"subcategory": Utils.better_capitalize(sub_category_line_edit.text.strip_edges()),
		"subcategory_img": sub_category_image_tag.text.strip_edges().to_lower(),
		"subcategory_desc": sub_category_desc.text.strip_edges(),
		"item_name": Utils.better_capitalize(item_name.text.strip_edges()),
		"item_desc": item_desc.text.strip_edges()
	}


func clear_fields() -> void:
	category_line_edit.clear()
	category_desc.clear()
	category_image_tag.clear()
	sub_category_line_edit.clear()
	sub_category_desc.clear()
	sub_category_image_tag.clear()
	item_name.clear()
	item_desc.clear()
	tag_line_edit.clear()


func on_save() -> void:
	var category_pick: String = Utils.better_capitalize(category_line_edit.text.strip_edges())
	var subcategory_pick: String = Utils.better_capitalize(sub_category_line_edit.text.strip_edges())
	var item_pick: String = Utils.better_capitalize(item_name.text.strip_edges())
	
	if display_target_tag:
		target_tag = tag_line_edit.text.strip_edges().to_lower()
	
	if category_pick.is_empty() or subcategory_pick.is_empty() or item_pick.is_empty() or target_tag.is_empty():
		highlight_errors()
		return
	
	if not Tagger.prompt_resources.prompt_list.has(category_pick):
		Tagger.prompt_resources.prompt_list[category_pick] = {
			"image_tag": category_image_tag.text.strip_edges().to_lower(),
			"desc": category_desc.text,
			"types": {}
		}
	elif force_key_save:
		Tagger.prompt_resources.prompt_list[category_pick]["image_tag"] = category_image_tag.text.strip_edges().to_lower()
		Tagger.prompt_resources.prompt_list[category_pick]["desc"] = category_desc.text
	
	if not Tagger.prompt_resources.prompt_list[category_pick]["types"].has(subcategory_pick):
		Tagger.prompt_resources.prompt_list[category_pick]["types"][subcategory_pick] = {
			"desc": sub_category_desc.text,
			"image_tag": sub_category_image_tag.text.strip_edges().to_lower(),
			"types": {}
		}
	elif force_key_save:
		Tagger.prompt_resources.prompt_list[category_pick]["types"][subcategory_pick]["desc"] = sub_category_desc.text
		Tagger.prompt_resources.prompt_list[category_pick]["types"][subcategory_pick]["image_tag"] = sub_category_image_tag.text.strip_edges().to_lower()
	
	Tagger.prompt_resources.prompt_list[category_pick]["types"][subcategory_pick]["types"][item_pick] = {
		"tag" = target_tag,
		"desc" = item_desc.text
	}
	
	Tagger.prompt_resources.save()
	prompt_done.emit()
	save.disabled = true
	save.text = "Done!"
	await get_tree().create_timer(1.5).timeout
	save.text = "Save"
	save.disabled = false


func on_cancel() -> void:
	prompt_done.emit()


func is_valid_prompt() -> bool:
	var category: bool = not category_line_edit.text.strip_edges().is_empty()
	var subcategory: bool = not sub_category_line_edit.text.strip_edges().is_empty()
	var item: bool = not item_name.text.strip_edges().is_empty()
	
	return category and subcategory and item


func fill_data(data_dict: Dictionary) -> void:
	category_line_edit.text = data_dict["category"]
	category_image_tag.text = data_dict["category_img"]
	category_desc.text = data_dict["category_desc"]
	sub_category_line_edit.text = data_dict["subcategory"]
	sub_category_image_tag.text = data_dict["subcategory_img"]
	sub_category_desc.text = data_dict["subcategory_desc"]
	item_name.text = data_dict["item_name"]
	item_desc.text = data_dict["item_desc"]


func load_prompt(category: String, subcategory: String, item: String) -> void:
	category_line_edit.text = category
	category_image_tag.text = Tagger.prompt_resources.prompt_list[category]["image_tag"]
	category_desc.text = Tagger.prompt_resources.prompt_list[category]["desc"]
	sub_category_line_edit.text = subcategory
	sub_category_image_tag.text = Tagger.prompt_resources.prompt_list[category]["types"][subcategory]["image_tag"]
	sub_category_desc.text = Tagger.prompt_resources.prompt_list[category]["types"][subcategory]["desc"]
	item_name.text = item
	item_desc.text = Tagger.prompt_resources.prompt_list[category]["types"][subcategory]["types"][item]["desc"]
	if display_target_tag:
		tag_line_edit.text = Tagger.prompt_resources.prompt_list[category]["types"][subcategory]["types"][item]["tag"]


func highlight_errors() -> void:
	if display_target_tag:
		if tag_line_edit.text.strip_edges().is_empty():
			print("TagEmptuy")
			tag_label.add_theme_color_override("font_color", Color.INDIAN_RED)
		elif tag_label.has_theme_color_override("font_color"):
			tag_label.remove_theme_color_override("font_color")
	
	if category_line_edit.text.strip_edges().is_empty():
		category_label.add_theme_color_override("font_color", Color.INDIAN_RED)
	elif category_label.has_theme_color_override("font_color"):
		category_label.remove_theme_color_override("font_color")
	
	if sub_category_line_edit.text.strip_edges().is_empty():
		sub_cat_label.add_theme_color_override("font_color", Color.INDIAN_RED)
	elif sub_cat_label.has_theme_color_override("font_color"):
		sub_cat_label.remove_theme_color_override("font_color")
	
	if item_name.text.strip_edges().is_empty():
		item_name_label.add_theme_color_override("font_color", Color.INDIAN_RED)
	elif item_name_label.has_theme_color_override("font_color"):
		item_name_label.remove_theme_color_override("font_color")
	
	error_timer.start()


func on_timer_timeout() -> void:
	if category_label.has_theme_color_override("font_color"):
		category_label.remove_theme_color_override("font_color")
	if sub_cat_label.has_theme_color_override("font_color"):
		sub_cat_label.remove_theme_color_override("font_color")
	if item_name_label.has_theme_color_override("font_color"):
		item_name_label.remove_theme_color_override("font_color")
	if tag_label.has_theme_color_override("font_color"):
			tag_label.remove_theme_color_override("font_color")


func enable_editing() -> void:
	disabled_rect.visible = false


func disable_editing() -> void:
	disabled_rect.visible = true
