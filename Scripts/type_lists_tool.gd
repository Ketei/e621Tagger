extends VBoxContainer

var tag_item = preload("res://Scenes/tag_list_item_scene.tscn")
@onready var lists_vbox: VBoxContainer = $ListsVBox
@onready var key_add: LineEdit = $AddMenu/KeyAdd
@onready var key_add_button: Button = $AddMenu/KeyAddButton


func _ready():
	for entry_list in Tagger.settings_lists.tag_types.keys():
		add_entry(entry_list, Tagger.settings_lists.tag_types[entry_list])
	key_add_button.pressed.connect(add_entry_btn_press)
	

func add_entry(key: String, line_list: Array = []) -> void:
	var new_item: TagListEntry = tag_item.instantiate()
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

