extends VBoxContainer

var tag_item = preload("res://Scenes/tag_list_item_scene.tscn")

var entry_tracker: Array[String] = []

@export var settings_variant: bool = true

@onready var lists_vbox: VBoxContainer = $ScrollContainer/ListsVBox
@onready var key_add: LineEdit = $AddMenu/KeyAdd
@onready var key_add_button: Button = $AddMenu/KeyAddButton


func _ready():
	if settings_variant:
		load_all_entries()
		key_add_button.pressed.connect(add_entry_btn_press)
		Tagger.reload_tag_groups.connect(load_all_entries)
	else:
		key_add_button.hide()
		key_add.hide()
	

func load_all_entries() -> void:
	for child in lists_vbox.get_children():
		child.queue_free()
	entry_tracker.clear()
	for entry_list in Tagger.settings_lists.tag_types.keys():
		add_entry(entry_list, Tagger.settings_lists.tag_types[entry_list])


func add_entry(key: String, line_list: Array = []) -> void:
	if entry_tracker.has(key):
		return
	
	entry_tracker.append(key)
	
	var new_item: TagListEntry = tag_item.instantiate()
	new_item.entry_removed.connect(entry_item_removed)
	if not settings_variant:
		new_item.enable_overwriting = false
	lists_vbox.add_child(new_item)
	new_item.set_key(key)
	new_item.set_entries(line_list)
	

func add_entry_btn_press() -> void:
	var key_to_check: String = key_add.text
	key_add.clear()
	
	if key_to_check.is_empty() or Tagger.settings_lists.tag_types.has(key_to_check):
		return
	
	Tagger.settings_lists.tag_types[key_to_check] = []
	add_entry(key_to_check)


func get_entry_items() -> Array:
	return lists_vbox.get_children()


func clear_all_items() -> void:
	for child in lists_vbox.get_children():
		if child.entry_removed.is_connected(entry_item_removed):
			child.entry_removed.disconnect(entry_item_removed)
		child.queue_free()


func entry_item_removed(entry_key: String, node_ref: Node) -> void:
	
	if entry_tracker.has(entry_key):
		entry_tracker.erase(entry_key)
	
	if is_instance_valid(node_ref):
		if node_ref.entry_removed.is_connected(entry_item_removed):
			node_ref.entry_removed.disconnect(entry_item_removed)

