class_name AutofillOptionTag
extends Control


signal tag_confirmed(tag_string)

var prefix_custom_id: int = 0
var suffix_custom_id: int = 0

var using_prefix: bool = false
var using_suffix: bool = false

var typed_tag: String = ""

@onready var prefix_option_button: OptionButton = $VBoxContainer/FieldsHBox/PrefixVBox/PrefixOptionButton
@onready var custom_prefix_line_edit: LineEdit = $VBoxContainer/FieldsHBox/PrefixVBox/CustomPrefixLineEdit
@onready var tag_name_line_edit: Label = $VBoxContainer/FieldsHBox/TagNameVbox/TagNameLineEdit
@onready var suffix_option_button: OptionButton = $VBoxContainer/FieldsHBox/SuffixVBox/SuffixOptionButton
@onready var custom_suffix_line_edit: LineEdit = $VBoxContainer/FieldsHBox/SuffixVBox/CustomSuffixLineEdit
@onready var cancel_button: Button = $VBoxContainer/ButtonsHBox/CancelButton
@onready var add_button: Button = $VBoxContainer/ButtonsHBox/AddButton

@onready var prefix_vbox: VBoxContainer = $VBoxContainer/FieldsHBox/PrefixVBox
@onready var suffix_vbox: VBoxContainer = $VBoxContainer/FieldsHBox/SuffixVBox


func _ready():
	add_button.pressed.connect(accept_tag)
	cancel_button.pressed.connect(cancel_tag)
	suffix_option_button.item_selected.connect(suffix_item_select)
	prefix_option_button.item_selected.connect(prefix_item_select)
	

func clear_fields() -> void:
	using_prefix = false
	using_suffix = false
	prefix_custom_id = 0
	suffix_custom_id = 0
	prefix_option_button.clear()
	suffix_option_button.clear()
	custom_prefix_line_edit.hide()
	custom_suffix_line_edit.hide()
	
	prefix_vbox.hide()
	suffix_vbox.hide()


func suffix_item_select(item_index: int) -> void:
	if item_index == suffix_custom_id:
		custom_suffix_line_edit.visible = true
	elif custom_suffix_line_edit.visible:
		custom_suffix_line_edit.visible = false


func prefix_item_select(item_index: int) -> void:
	if item_index == prefix_custom_id:
		custom_prefix_line_edit.visible = true
	elif custom_prefix_line_edit.visible:
		custom_prefix_line_edit.visible = false


func open_with_tag(suggested_custom: String, prefix_key: String = "", suffix_key: String = "") -> void:
	clear_fields()
	
	suggested_custom = suggested_custom.trim_prefix("*"+prefix_key+"*").trim_suffix("*"+suffix_key+"*").strip_edges()
	
	if not prefix_key.is_empty():
		using_prefix = true
		
		if Tagger.settings_lists.tag_types.has(prefix_key):
			for prefix in Tagger.settings_lists.tag_types[prefix_key]:
				prefix_option_button.add_item(prefix.trim_suffix(suggested_custom).strip_edges())
		
		prefix_option_button.add_item("- custom -")
		prefix_custom_id = prefix_option_button.item_count - 1
		prefix_option_button.select(0)
		prefix_item_select(0)
		prefix_vbox.show()

	if not suffix_key.is_empty():
		using_suffix = true
		
		if Tagger.settings_lists.tag_types.has(suffix_key):
			for suffix in Tagger.settings_lists.tag_types[suffix_key]:
				suffix_option_button.add_item(suffix.trim_prefix(suggested_custom).strip_edges())
		
		suffix_option_button.add_item("- custom -")
		suffix_custom_id = suffix_option_button.item_count - 1
		suffix_option_button.select(0)
		suffix_item_select(0)
		suffix_vbox.show()
	
	tag_name_line_edit.text = suggested_custom
	typed_tag = suggested_custom


func accept_tag() -> void:
	var constructed_string: String = ""
	
	if using_prefix:
		if prefix_option_button.selected == prefix_custom_id:
			constructed_string += custom_prefix_line_edit.text + " "
		else:
			constructed_string += get_prefix_selected() + " "
	
	constructed_string += typed_tag
	
	if using_suffix:
		if suffix_option_button.selected == suffix_custom_id:
			constructed_string += " " + custom_suffix_line_edit.text
		else:
			constructed_string += " " + get_suffix_selected()
	
	tag_confirmed.emit(constructed_string)


func cancel_tag() -> void:
	tag_confirmed.emit("")


func get_valid_somefix(string_tag: String) -> Dictionary:
	var is_valid_fix: bool = false
	
	var prefix_found: String = ""
	var suffix_found: String = ""
	
	if string_tag.begins_with("*"):
		for character in string_tag.erase(0, 1):
			if character == "*":
				is_valid_fix = true
				break
			else:
				prefix_found += character
	
	if is_valid_fix:
		is_valid_fix = false
	else:
		prefix_found = ""
	
	if string_tag.ends_with("*"):
		var reversed_string_array: Array = string_tag.left(-1).split()
		var string_construct: PackedStringArray = []
		reversed_string_array.reverse()
	
		for character in reversed_string_array:
			if character == "*":
				is_valid_fix = true
				break
			else:
				string_construct.insert(0, character)
		
		if is_valid_fix:
			suffix_found = "".join(string_construct)
		else:
			suffix_found = ""
		
	return {"prefix": prefix_found, "suffix": suffix_found}


func get_suffix_selected() -> String:
	return suffix_option_button.get_item_text(
			suffix_option_button.selected)


func get_prefix_selected() -> String:
	return prefix_option_button.get_item_text(
			prefix_option_button.selected)

