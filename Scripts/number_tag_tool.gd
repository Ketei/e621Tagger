class_name NumberTagTool
extends Control


signal number_chosen(numbered_string)

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
	var formatted_string = str(number_spinbox.value) + " " + tag_numbered.text
	if number_spinbox.value != 1:
		formatted_string += "s"
	number_chosen.emit(formatted_string)


func cancel_tag_number() -> void:
	number_chosen.emit("")

