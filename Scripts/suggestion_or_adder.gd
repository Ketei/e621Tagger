class_name  SuggestionOrAdder
extends Control


signal option_selected(option_string)

@onready var tags_option_button: OptionButton = $HBoxContainer/TagsOptionButton
@onready var accept_button: Button = $HBoxContainer/AcceptButton
@onready var cancel_button: Button = $HBoxContainer/CancelButton


func _ready():
	accept_button.pressed.connect(accept_selected)
	cancel_button.pressed.connect(cancel_selection)
	

func populate_menu(or_string: String) -> void:
	or_string = or_string.trim_prefix("|").trim_suffix("|")
	tags_option_button.clear()
	
	for items in or_string.split(",", false):
		tags_option_button.add_item(items.strip_edges())
	
	if 0 < tags_option_button.item_count:
		tags_option_button.select(0)


func accept_selected() -> void:
	var return_string: String = ""
	
	if 0 < tags_option_button.item_count:
		return_string = tags_option_button.get_item_text(tags_option_button.selected)

	option_selected.emit(return_string)


func cancel_selection() -> void:
	option_selected.emit("")

