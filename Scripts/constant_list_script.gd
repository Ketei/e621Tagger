extends VBoxContainer

#var constant_tags: Array[String] = []

@onready var constants_line_edit = $ConstantsLineEdit
@onready var constants_item_list = $ConstantsItemList


func _ready():
	for item in Tagger.settings_lists.constant_tags:
		constants_item_list.add_item(item)
#		constant_tags.append(item)
	constants_item_list.sort_items_by_text()
	
	constants_item_list.item_activated.connect(remove_constant)
	constants_line_edit.text_submitted.connect(add_constant)


func add_constant(new_constant: String) -> void:
	new_constant = new_constant.to_lower().strip_edges()
	
	if new_constant.is_empty():
		return
	
	if Tagger.settings_lists.constant_tags.has(new_constant):
		constants_line_edit.clear()
		return
	
	constants_item_list.add_item(new_constant)
#	constant_tags.append(new_constant)
	Tagger.settings_lists.constant_tags.append(new_constant)
	constants_line_edit.clear()


func remove_constant(constant_id: int) -> void:
	var constant_name: String = constants_item_list.get_item_text(constant_id)
#	constant_tags.remove_at(constant_id)
	constants_item_list.remove_item(constant_id)
	Tagger.settings_lists.remove_from_constant_tags(constant_name)

