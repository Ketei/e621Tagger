extends OptionButton

@onready var final_tag_list: TextEdit = $"../FinalList/FinalTagList"
@onready var tag_list_generator = $"../TagListGenerator"
@onready var tagger = $".."

func _ready():
	selected = Tagger.site_settings.target_site
	item_selected.connect(change_platform)


func change_platform(index_value: int) -> void:
	tag_list_generator.target_site = get_item_id(index_value)
	if not tagger.final_tag_list_array.is_empty():
		final_tag_list.text = tag_list_generator.create_list_from_array(
				tagger.final_tag_list_array
		)
