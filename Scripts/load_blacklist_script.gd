extends VBoxContainer
@onready var load_bl_line_edit: LineEdit = $LoadBLLineEdit
@onready var load_blacklist_item_list: ItemList = $LoadBlacklistItemList


func _ready():
	for load_black in Tagger.settings_lists.loader_blacklist:
		load_blacklist_item_list.add_item(load_black)
	load_blacklist_item_list.sort_items_by_text()
	
	load_bl_line_edit.text_submitted.connect(add_to_blacklist)
	load_blacklist_item_list.item_activated.connect(remove_from_blacklist)


func add_to_blacklist(tag_to_add: String) -> void:
	tag_to_add = tag_to_add.strip_escapes().strip_edges()
	load_bl_line_edit.clear()
	if tag_to_add.is_empty():
		return
		
	if not Tagger.settings_lists.loader_blacklist.has(tag_to_add):
		Tagger.settings_lists.loader_blacklist.append(tag_to_add)
		load_blacklist_item_list.add_item(tag_to_add)


func remove_from_blacklist(item_id: int) -> void:
	Tagger.settings_lists.loader_blacklist.erase(
			load_blacklist_item_list.get_item_text(item_id))
	load_blacklist_item_list.remove_item(item_id)

