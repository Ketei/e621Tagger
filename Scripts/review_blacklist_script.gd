extends VBoxContainer


@onready var sugg_blacklist_line_edit = $SuggBlacklistLineEdit
@onready var sugg_blacklist_item_list = $SuggBlacklistItemList


func _ready():
	for blacktag in Tagger.settings_lists.suggestion_review_blacklist:
		sugg_blacklist_item_list.add_item(blacktag)
	
	sugg_blacklist_line_edit.text_submitted.connect(add_to_sugg_blacklist)
	sugg_blacklist_item_list.item_activated.connect(remove_from_sugg_blacklist)


func add_to_sugg_blacklist(new_tag: String) -> void:
	new_tag = new_tag.strip_edges().to_lower()
	
	if new_tag.is_empty():
		sugg_blacklist_line_edit.clear()
		return
	
	Tagger.settings_lists.suggestion_review_blacklist.append(new_tag)
	sugg_blacklist_item_list.add_item(new_tag)
	sugg_blacklist_line_edit.clear()


func remove_from_sugg_blacklist(item_index: int) -> void:
	var tag_name: String = sugg_blacklist_item_list.get_item_text(item_index)
	Tagger.settings_lists.remove_from_suggestion_review_blacklist(tag_name)
	sugg_blacklist_item_list.remove_item(item_index)
	
	
