extends Control

@onready var main_application: MainTagger = $".."

@onready var preview_list = %PreviewList
@onready var input_tags = %InputTags

@onready var preview_tags: Button = %PreviewTags
@onready var transfer_tags: Button  = %TransferTags

@onready var whitespace = %Whitespace
@onready var separator = %Separator

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


func generate_preview() -> void:
	preview_list.clear()
	
	var array_string: String = input_tags.text
	array_string = array_string.replace("\n", " ")
	array_string = array_string.strip_escapes()
	array_string = array_string.to_lower()
	
	if separator.text == "" or whitespace.text == "":
		return

	var _tags: Array = array_string.split(separator.text, false)
	
	var _final_array: Array[String] = []
	
	var preview_append: String = ""
	
	for item in _tags:
		preview_append = item.strip_edges().replace(whitespace.text, " ")
		if not _final_array.has(preview_append):
			_final_array.append(preview_append)

	for item in _final_array:
		preview_list.add_item(item)


func send_tags() -> void:	
	if separator.text == "" or whitespace.text == "":
		return
	
	var array_string: String = input_tags.text
	array_string = array_string.replace("\n", " ")
	array_string = array_string.strip_escapes().strip_edges()
	
	var _tags: Array = array_string.split(separator.text, false)
	var _return_array: Array = []
	
	var item_append: String = ""
	
	for item in _tags:
		item_append = item.strip_edges().replace(whitespace.text, " ").to_lower()
		if not _return_array.has(item_append):
			_return_array.append(item_append)

	main_application.load_tags(_return_array, check_box.button_pressed)
	
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
