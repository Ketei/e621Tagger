extends Control

@onready var add_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TypeLists/AddMenu/AddButton
@onready var key_line: LineEdit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TypeLists/AddMenu/KeyLine
@onready var type_lists = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TypeLists
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CloseButton


func _ready():
	hide()
	add_button.pressed.connect(add_group)
	close_button.pressed.connect(hide)


func add_group() -> void:
	var new_key: String = key_line.text.strip_edges().to_lower()
	key_line.clear()
	
	if new_key.is_empty():
		return

	type_lists.add_entry(new_key)


func load_group(key: String, values: Array) -> void:
	type_lists.add_entry(key, values)


func get_tag_types_entries() -> Dictionary:
	var return_dict: Dictionary = {}
	for item:TagListEntry in type_lists.get_entry_items():
		return_dict[item.key_line_edit.text] = []
		for entry:String in item.entries_line_edit.text.split(",", false):
			if not return_dict[item.key_line_edit.text].has(entry):
				return_dict[item.key_line_edit.text].append(entry.strip_edges().to_lower())
	
	return return_dict


func clean_all() -> void:
	type_lists.clear_all_items()


