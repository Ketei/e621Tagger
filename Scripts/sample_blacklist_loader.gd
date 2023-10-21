extends Control

@onready var sample_blacklist_item_list: ItemList = $SampleBlacklistItemList
@onready var sample_blacklist_line_edit: LineEdit = $SampleBlacklistLineEdit


func _ready():
	for black_tag in Tagger.settings_lists.samples_blacklist:
		sample_blacklist_item_list.add_item(black_tag)
	
	sample_blacklist_item_list.item_activated.connect(remove_from_sample_blacklist)
	sample_blacklist_line_edit.text_submitted.connect(add_to_sample_blacklist)


func add_to_sample_blacklist(new_item: String) -> void:
	Tagger.settings_lists.samples_blacklist.append(new_item)
	sample_blacklist_item_list.add_item(new_item)
	sample_blacklist_line_edit.clear()


func remove_from_sample_blacklist(item_index: int) -> void:
	var tag_name: String = sample_blacklist_item_list.get_item_text(item_index)
	Tagger.settings_lists.remove_from_sample_blacklist(tag_name)
	sample_blacklist_item_list.remove_item(item_index)
	
