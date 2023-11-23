class_name NumberTagTool
extends Control


signal number_chosen(numbered_string)

const es_suffixes: Array[String] = ["s", "x", "z", "sh", "ch"]
#const vowels: Array[String] = ["a", "e", "i", "o", "u"]

@onready var number_spinbox: SpinBox = $HBoxContainer/SpinBox
@onready var tag_numbered: Label = $HBoxContainer/NumerTag
@onready var accept_button: Button = $HBoxContainer/AcceptButton
@onready var cancel_button: Button = $HBoxContainer/CancelButton


func _ready():
	accept_button.pressed.connect(accept_tag_number)
	cancel_button.pressed.connect(cancel_tag_number)


func set_tool(tag_to_set: String) -> void:
	tag_numbered.text = tag_to_set.to_lower().strip_edges()
	number_spinbox.set_value_no_signal(1)


func accept_tag_number() -> void:
	var multiple_suffix: String = ""
	
	# This part should add proper plurals to words ending with "y"
	# It's experimental though and I don't want to test.
	# If cases come up where the proper plural of words ending in "y" is
	# required, just uncomment the 5 lines of code below and delete this
	# comment. Also uncomment the constant array containing bowels above.
	
#	if tag_numbered.text.ends_with("y"):
#		var remove_y: String = tag_numbered.text.left(-1)
#		if not remove_y.is_empty():
#			if not vowels.has(remove_y.right(1)):
#				tag_numbered.text = remove_y + "ie"
	
	for ending in es_suffixes:
		if tag_numbered.text.ends_with(ending):
			multiple_suffix = "es"

	if multiple_suffix.is_empty():
		multiple_suffix = "s"
	
	var formatted_string = str(number_spinbox.value) + " " + tag_numbered.text
	if number_spinbox.value != 1:
		formatted_string += multiple_suffix
	number_chosen.emit(formatted_string)


func cancel_tag_number() -> void:
	number_chosen.emit("")

