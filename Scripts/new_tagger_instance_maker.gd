extends Control

@onready var instance_name_line_edit: LineEdit = $CenterContainer/Control/NewInstanceLineEdit
@onready var create_instance_button: Button = $CenterContainer/Control/CreateInstanceButton
@onready var tagger_holder = $".."
@onready var close_button: Button = $CenterContainer/Control/CloseWindowButton
@onready var new_tagger = $".."


func _ready():
	hide()
	instance_name_line_edit.text_submitted.connect(create_instance)
	instance_name_line_edit.text_changed.connect(text_changed)
	create_instance_button.pressed.connect(submit_button_press)
	close_button.pressed.connect(close_window)


func text_changed(new_text: String) -> void:
	new_text = new_text.strip_edges().to_lower()
	create_instance_button.disabled = (tagger_holder.instance_dictionary.has(new_text) or new_text.is_empty())
	
	var is_valid_instance: bool = new_tagger.can_create_instance(new_text)
	
	if is_valid_instance:
		instance_name_line_edit.add_theme_color_override("font_color", Color.MEDIUM_AQUAMARINE)
	else:
		instance_name_line_edit.add_theme_color_override("font_color", Color.INDIAN_RED)
	

func submit_button_press() -> void:
	create_instance(instance_name_line_edit.text)


func create_instance(instance_to_create: String) -> void:
	instance_to_create = instance_to_create.strip_edges().to_lower()
	
	if instance_to_create.is_empty() or tagger_holder.instance_dictionary.has(instance_to_create):
		return
	
	tagger_holder.create_new_tagger(instance_to_create.to_lower())
	clear_text()
	hide()


func clear_text() -> void:
	instance_name_line_edit.text = ""
	instance_name_line_edit.text_changed.emit("")


func close_window() -> void:
	clear_text()
	hide()

