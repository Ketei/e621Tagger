extends Control

@onready var main_application: MainTagger = $".."

@onready var preview_list = %PreviewList
@onready var input_tags: TextEdit = %InputTags

@onready var preview_tags: Button = %PreviewTags
@onready var transfer_tags: Button  = %TransferTags

@onready var whitespace: TextEdit = %Whitespace
@onready var separator: TextEdit = %Separator

@onready var check_box = %CheckBox


var timer_text: Timer


func _ready():
	hide()
	transfer_tags.pressed.connect(send_tags)
	preview_tags.pressed.connect(generate_preview)
	timer_text = Timer.new()
	timer_text.autostart = false
	timer_text.wait_time = 2.0
	timer_text.one_shot = true
	timer_text.timeout.connect(_timer_timeout)
	add_child(timer_text)


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


func generate_preview() -> void:
	preview_list.clear()

	for item in generate_tags_array(input_tags.text.strip_escapes().strip_edges(), separator.text, whitespace.text):
		preview_list.add_item(item)


func send_tags() -> void:	

	main_application.load_tags(
			generate_tags_array(
					input_tags.text.strip_escapes().strip_edges(),
					separator.text,
					whitespace.text),
			check_box.button_pressed)
	
	transfer_tags.text = "Success!"
	timer_text.start()
	clear_boxes()


func clear_boxes() -> void:
	input_tags.clear()
	preview_list.clear()
	separator.clear()
	whitespace.clear()


func _timer_timeout():
	transfer_tags.text = "Transfer tags"
