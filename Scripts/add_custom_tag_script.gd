class_name AutofillOptionTag
extends Control

signal tag_confirmed(tag_string)

enum Modes {
	PREFIX,
	SUFFIX,
}

var prefix_array: Array = []
var prefix_custom_id: int = 0
var suffix_array: Array = []
var suffix_custom_id: int = 0

var mode := Modes.PREFIX

var typed_tag: String = ""
var types_array: Array = []

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
	prefix_array.clear()
	suffix_array.clear()
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


func open_with_tag(suggested_custom: String, somefix_key: String) -> void:
	clear_fields()
	
	if suggested_custom.begins_with("*"):
		mode = Modes.PREFIX
#		var types_key = suggested_custom.left(3)
#		types_key = types_key.trim_prefix("*").trim_suffix("*")
		
		types_array.clear()
		
		if Tagger.settings_lists.tag_types.has(somefix_key):
			types_array = Tagger.settings_lists.tag_types[somefix_key].duplicate()
		
		suggested_custom = suggested_custom.trim_prefix("*" + somefix_key + "*").strip_edges()
		
		for prefix in types_array:
			prefix_option_button.add_item(prefix.trim_suffix(suggested_custom).strip_edges())
		
		prefix_option_button.add_item("- custom -")
		prefix_custom_id = prefix_option_button.item_count - 1
		prefix_option_button.select(0)
		prefix_item_select(prefix_option_button.selected)
		prefix_vbox.show()

	elif suggested_custom.ends_with("*"):
		mode = Modes.SUFFIX
#		var types_key = suggested_custom.right(3)
#		types_key = types_key.trim_prefix("*").trim_suffix("*")
		
		types_array.clear()
		
		if Tagger.settings_lists.tag_types.has(somefix_key):
			types_array = Tagger.settings_lists.tag_types[somefix_key].duplicate()
		
		suggested_custom = suggested_custom.trim_suffix("*" + somefix_key + "*").strip_edges()
		
		for suffix in types_array:
			suffix_option_button.add_item(suffix.trim_prefix(suggested_custom).strip_edges())
		
		suffix_option_button.add_item("- custom -")
		suffix_custom_id = suffix_option_button.item_count - 1
		suffix_option_button.select(0)
		suffix_item_select(suffix_option_button.selected)
		suffix_vbox.show()
	
	tag_name_line_edit.text = suggested_custom
	typed_tag = suggested_custom


func accept_tag() -> void:
	if mode == Modes.PREFIX:
		if prefix_option_button.selected == prefix_custom_id:
			tag_confirmed.emit(
				custom_prefix_line_edit.text + " " + typed_tag
			)
		else:
			tag_confirmed.emit(
				types_array[prefix_option_button.selected] + " " + typed_tag
			)
	else:
		if suffix_option_button.selected == suffix_custom_id:
			tag_confirmed.emit(
				typed_tag + " " + custom_suffix_line_edit.text
			)
		else:
			tag_confirmed.emit(
				typed_tag + " " + types_array[suffix_option_button.selected]
			)


func cancel_tag() -> void:
	tag_confirmed.emit("")


func get_valid_somefix(string_tag: String) -> String:
	var from_start: bool = false
	var tag_construct: String = ""
	var is_valid_fix: bool = false
	
	if string_tag.begins_with("*"):
		from_start = true

	if from_start:
		for character in string_tag.erase(0, 1):
			if character == "*":
				is_valid_fix = true
				break
			else:
				tag_construct += character
	else:
		var reversed_string_array: Array = string_tag.left(-1).split()
		var string_construct: PackedStringArray = []
		reversed_string_array.reverse()
		
		for character in reversed_string_array:
			if character == "*":
				is_valid_fix = true
				break
			else:
				string_construct.insert(0, character)
		
		tag_construct = "".join(string_construct)
		
	if is_valid_fix:
		return tag_construct
	else:
		return ""






