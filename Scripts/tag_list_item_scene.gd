class_name TagListEntry
extends HBoxContainer

signal entry_removed(entry_name, node_ref)

@export var enable_overwriting: bool = true

@onready var key_line_edit: LineEdit = $KeyLineEdit
@onready var entries_line_edit: LineEdit = $EntriesLineEdit
@onready var save_button: Button = $HBoxContainer/SaveButton
@onready var delete_button: Button = $HBoxContainer/DeleteButton
@onready var sort_check_box: CheckBox = $HBoxContainer/SortCheckBox


func _ready():
	if enable_overwriting:
		save_button.pressed.connect(save_entries)
	else:
		save_button.hide()
	
	delete_button.pressed.connect(delete_entry)


func set_key(key: String) -> void:
	key_line_edit.text = key


func set_can_sort(can_sort: bool) -> void:
	sort_check_box.button_pressed = can_sort


func set_entries(entries_array: Array) -> void:
	entries_line_edit.text = Utils.array_to_string(entries_array)


func save_entries() -> void:
	var entries_array: Array = entries_line_edit.text.split(",", false)
	var final_array: Array = []
	
	for entry in entries_array:
		final_array.append(entry.strip_edges())
	
	if sort_check_box.button_pressed:
		final_array.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	
	Tagger.settings_lists.tag_types[key_line_edit.text] = {
		"tags": final_array,
		"sort": sort_check_box.button_pressed
		}
	
	entries_line_edit.text = Utils.array_to_string(final_array)
	
	save_button.text = "Saved!"
	save_button.disabled = true
	await get_tree().create_timer(1).timeout
	save_button.text = "Save"
	save_button.disabled = false


func delete_entry() -> void:
	if enable_overwriting:
		Tagger.settings_lists.tag_types.erase(key_line_edit.text)
	entry_removed.emit(key_line_edit.text, self)
	queue_free.call_deferred()

