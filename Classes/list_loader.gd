extends Control

@onready var main_application: MainTagger = $".."

@onready var preview_list = %PreviewList
@onready var input_tags: TextEdit = %InputTags

@onready var preview_tags: Button = %PreviewTags
@onready var transfer_tags: Button  = %TransferTags

@onready var whitespace: TextEdit = %Whitespace
@onready var separator: TextEdit = %Separator
@onready var text_timer = $TextTimer
@onready var list_namer = $ListNamer


func _ready():
	transfer_tags.pressed.connect(show_list_namer)
	preview_tags.pressed.connect(generate_preview)
	text_timer.timeout.connect(_timer_timeout)


func show_list_namer() -> void:
	if not input_tags.text.replace("\n", " ").replace(whitespace.text, " ").strip_edges().strip_escapes().is_empty():
		list_namer.show_and_focus()


func generate_tags_array(input_string: String, split_char: String = "", whitespace_char: String = "") -> PackedStringArray:
	var _split_tags: Array = []
	var _whitespaced_tags: Array = []
	var final_array: PackedStringArray = []
	
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
	
	for item in _whitespaced_tags:
		if not item in Tagger.settings_lists.loader_blacklist:
			final_array.append(item)
	
	return final_array


func generate_preview() -> void:
	preview_list.clear()
	for item in generate_tags_array(input_tags.text.replace("\n", " ").strip_escapes().strip_edges(), separator.text, whitespace.text):
		preview_list.add_item(Tagger.alias_database.get_alias(item))


func clear_boxes() -> void:
	input_tags.clear()
	preview_list.clear()
	separator.clear()
	whitespace.clear()


func _timer_timeout():
	transfer_tags.text = "Transfer tags"

