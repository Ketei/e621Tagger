extends VBoxContainer


@onready var black_list = $BlackList
@onready var add_to_black = $AddToBlack


func _ready():
	add_to_black.text_submitted.connect(add_to_blacklist)
	black_list.item_activated.connect(remove_from_blacklist)
	
	for item in Tagger.settings_lists.suggestion_blacklist:
		black_list.add_item(item)


func add_to_blacklist(new_item: String) -> void:
	new_item = new_item.to_lower().strip_edges()
	
	if new_item.is_empty():
		return
	
	if Tagger.settings_lists.suggestion_blacklist.has(new_item):
		return
	
	black_list.add_item(new_item)
	Tagger.settings_lists.add_to_blacklist(new_item)
	add_to_black.clear()


func remove_from_blacklist(index_id) -> void:
	var _target = black_list.get_item_text(index_id)
	black_list.remove_item(index_id)
	Tagger.settings_lists.remove_from_blacklist(_target)

