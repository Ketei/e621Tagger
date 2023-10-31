extends Control

@onready var name_creator_line_edit: LineEdit = $CenterContainer/NamingWindow/CenterContainer/VBoxContainer/NameCreatorLineEdit
@onready var load_tags_button: Button = $CenterContainer/NamingWindow/CenterContainer/VBoxContainer/HBoxContainer/LoadTagsButton
@onready var new_tagger = $"../../NewTagger"

@onready var input_tags: TextEdit = %InputTags
@onready var separator: TextEdit = %Separator
@onready var whitespace: TextEdit = %Whitespace
@onready var cancel_load_button: Button = $CenterContainer/NamingWindow/CenterContainer/VBoxContainer/HBoxContainer/CancelLoadButton
@onready var list_loader = $".."
@onready var main_application = $"../.."


func _ready():
	hide()
	name_creator_line_edit.text_changed.connect(line_text_changed)
	cancel_load_button.pressed.connect(cancel_load_pressed)
	name_creator_line_edit.text_submitted.connect(submit_instance_name)
	load_tags_button.pressed.connect(load_tags_button_pressed)


func generate_tags_array(input_string: String, split_char: String = "", whitespace_char: String = "") -> PackedStringArray:
	var _split_tags: PackedStringArray = []
	var _whitespaced_tags: PackedStringArray = []
	
	if input_string.is_empty():
		return PackedStringArray()
	
	if split_char.is_empty():
		_split_tags.append(input_string)
	else:
		_split_tags = input_string.split(split_char, false)
	
	if whitespace_char.is_empty():
		_whitespaced_tags.append_array(_split_tags)
	else:
		for tag in _split_tags:
			_whitespaced_tags.append(tag.replace(whitespace_char, " ").strip_edges())
	
	return _whitespaced_tags


func line_text_changed(new_text: String) -> void:
	var is_valid_instance: bool = new_tagger.can_create_instance(new_text)
	load_tags_button.disabled = not (is_valid_instance or new_text.is_empty())
	
	if is_valid_instance:
		name_creator_line_edit.add_theme_color_override("font_color", Color.MEDIUM_AQUAMARINE)
	else:
		name_creator_line_edit.add_theme_color_override("font_color", Color.INDIAN_RED)


func load_tags_button_pressed() -> void:
	submit_instance_name(name_creator_line_edit.text)


func submit_instance_name(new_instance_name: String) -> void:
	if new_tagger.can_create_instance(new_instance_name) or new_instance_name.is_empty():
		new_tagger.load_tags(
				generate_tags_array(
						input_tags.text,
						separator.text,
						whitespace.text),
				new_instance_name)
		clean_text()
		list_loader.clear_boxes()
		hide()
		main_application.trigger_options(0)


func clean_text() -> void:
	name_creator_line_edit.clear()


func cancel_load_pressed() -> void:
	clean_text()
	hide()



