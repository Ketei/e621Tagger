extends VBoxContainer

@onready var invalid_tags_line_edit = $InvalidTagsLineEdit
@onready var invalid_tag_list = $InvalidItemList


func _ready() -> void:
	for invalid_tag in Tagger.settings_lists.invalid_tags:
		invalid_tag_list.add_item(invalid_tag)
	invalid_tag_list.sort_items_by_text()
	invalid_tags_line_edit.text_submitted.connect(add_to_invalid_tags)
	invalid_tag_list.item_activated.connect(remove_from_invalids)
	

func add_to_invalid_tags(tag_to_add: String) -> void:
	tag_to_add = tag_to_add.strip_edges().to_lower()
	if tag_to_add.is_empty():
		return
	if not Tagger.settings_lists.invalid_tags.has(tag_to_add):
		invalid_tag_list.add_item(tag_to_add)
		Tagger.settings_lists.invalid_tags.append(tag_to_add)
	invalid_tags_line_edit.clear()


func remove_from_invalids(tag_id: int) -> void:
	var tag_text: String = invalid_tag_list.get_item_text(tag_id)
	invalid_tag_list.remove_item(tag_id)
	Tagger.settings_lists.remove_from_invalids(tag_text)

