class_name TagListEntry
extends HBoxContainer


@onready var key_line_edit: LineEdit = $KeyLineEdit
@onready var entries_line_edit: LineEdit = $EntriesLineEdit
@onready var save_button: Button = $HBoxContainer/SaveButton
@onready var delete_button: Button = $HBoxContainer/DeleteButton


func _ready():
	save_button.pressed.connect(save_entries)
	delete_button.pressed.connect(delete_entry)


func set_key(key: String) -> void:
	key_line_edit.text = key


func set_entries(entries_array: Array) -> void:
	entries_line_edit.text = Utils.array_to_string(entries_array)


func save_entries() -> void:
	var entries_array: Array = entries_line_edit.text.split(",", false)
	var final_array: Array = []
	
	for entry in entries_array:
		final_array.append(entry.strip_edges())
	
	Tagger.settings_lists.tag_types[key_line_edit.text] = final_array
	
	save_button.text = "Saved!"
	save_button.disabled = true
	await get_tree().create_timer(1).timeout
	save_button.text = "Save"
	save_button.disabled = false

func delete_entry() -> void:
	Tagger.settings_lists.tag_types.erase(key_line_edit.text)
	queue_free()

